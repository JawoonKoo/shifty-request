# frozen_string_literal: true

module ShiftyRequest
  module Service
    class MakeAttendanceService
      def run(date:, attendance:, working_time:)
        if attendance.nil?
          Model::CreateAttendance.new(date)
        elsif !attendance.clock_time.proper_time?(working_time)
          Model::EditAttendance.new(attendance)
        end
      end
    end
  end
end
