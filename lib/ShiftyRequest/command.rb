# frozen_string_literal: true

module ShiftyRequest
  class Command
    class << self
      def run(argv)
        new(argv).run
      rescue => e
        puts e.message
      end
    end
    def initialize(argv)
      @edit_attendance_request = Request::EditAttendance.new
      @create_attendance_request = Request::CreateAttendance.new
      @load_attendance = Request::LoadAttendance.new
      @make_attendance_service = Service::MakeAttendanceService.new
      @argv = argv
    end

    def run
      target_date_env = ENV['TARGET_DATE']
      
      if target_date_env
        target_date = Date.parse(target_date_env)
        edit_month = target_date.to_time
        working_time = load_working_time
        attendances = load_attendances_history(working_time:, edit_month:)
        
        range_start = target_date
        range_end = target_date
      else
        edit_month = load_edit_month
        working_time = load_working_time
        attendances = load_attendances_history(working_time:, edit_month:)

        range_start = edit_month.to_date
        range_end = [edit_month.end_of_month.to_date, Date.today].min
      end
      
      skip_dates = ENV['SKIP_DATES']&.split(',')&.map(&:strip) || []

      requests = (range_start..range_end).map do |date|
        next if !target_date_env && Extend::DateUtil.holiday?(date)
        next if skip_dates.include?(date.to_s)

        attendance = attendances.find { |a| a.clock_time.in_time.to_date == date }
        @make_attendance_service.run(date:, attendance:, working_time:)
      end.compact

      puts requests.map { |req| req.to_s(working_time) }

      if requests.empty?
        puts '수정/생성할 기록이 없습니다.'
        return
      end

      puts '해당 기록을 반영하시겠습니까? (Y/N)'
      answer = gets.chomp
      if answer == 'Y' || answer == 'y'
        send_requests(requests, working_time)
      end
    end

    def load_edit_month
      puts '수정할 출퇴근 기록의 기간을 선택해주세요.'
      puts "1. 저번 달 (#{Date.today.prev_month.strftime("%Y년 %m월")})"
      puts "2. 이번 달 (#{Date.today.strftime("%Y년 %m월")})"
      answer = gets.chomp

      result = if answer == '1'
        Time.now.prev_month
      elsif answer == '2'
        Time.now.beginning_of_month
      else
        puts '잘못된 입력입니다.'
        load_edit_month
      end
      result
    end

    def load_working_time
      puts '정해진 출퇴근 시간을 가져옵니다.'
      ShiftyRequest::Model::WorkingTime.new(
        Time.parse(ENV['WORK_START_TIME']),
        Time.parse(ENV['WORK_FINISH_TIME']),
      )
    end

    def load_attendances_history(working_time:, edit_month:)
      puts '출퇴근 기록을 불러옵니다.'
      @load_attendance.request(edit_month:)
    end

    def send_requests(requests, working_time)
      create_tasks = requests.select { |r| r.is_a?(Model::CreateAttendance) }
      edit_tasks = requests.select { |r| r.is_a?(Model::EditAttendance) }

      if create_tasks.any?
        puts '출퇴근 기록 생성을 시작합니다.'
        @create_attendance_request.call(create_attendances: create_tasks, working_time:)
      end

      if edit_tasks.any?
        puts '출퇴근 기록 수정을 시작합니다.'
        @edit_attendance_request.call(edit_attendances: edit_tasks, working_time:)
      end
    end
  end
end
