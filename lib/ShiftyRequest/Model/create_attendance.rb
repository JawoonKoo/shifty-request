# frozen_string_literal: true

module ShiftyRequest
  module Model
    class CreateAttendance
      attr_reader :date

      def initialize(date)
        @date = date
      end

      def self.target_date(date)
        new(date)
      end

      def clock_time(working_time)
        return @clock_time if defined?(@clock_time)

        start_base = align_time(date, working_time.in_time)
        # Start Time: 10:00 - 6 min ~ 10:00 - 1 sec (Always earlier)
        in_offset = rand(-360..-1)
        in_time = start_base + in_offset

        end_base = align_time(date, working_time.out_time)
        # End Time: 19:00 + 1 sec ~ 19:00 + 6 min (Always later)
        out_offset = rand(1..360)
        out_time = end_base + out_offset

        @clock_time = ClockTime.new(in_time, out_time)
      end

      def to_s(working_time)
        ct = clock_time(working_time)
        "출퇴근 기록 생성: 날짜: #{@date}, 출근: #{ct.in_time}, 퇴근: #{ct.out_time}"
      end

      private

      def align_time(date, time)
        Time.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.utc_offset)
      end
    end
  end
end
