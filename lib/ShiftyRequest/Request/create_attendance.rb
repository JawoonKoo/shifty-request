# frozen_string_literal: true

module ShiftyRequest
  module Request
    class CreateAttendance < APIRequest
      def url
        super + '/request'
      end

      def call(create_attendances:, working_time:)
        create_attendances.each do |attendance|
          puts body(attendance, working_time)
          response = HTTParty.post(url, headers: headers, body: body(attendance, working_time))
          puts response
        end
      end

      def body(create_attendance, working_time)
        clock_time = create_attendance.clock_time(working_time)
        {
          'approval_sequence': [
            1,
          ],
          'requested_employee_ids_sequence': [
            [
              ENV['REQUESTED_EMPLOYEE_ID']&.to_i,
            ],
          ],
          'followed_employee_ids_sequence': [
            [],
          ],
          data: {
            'requestType': 'create_attendance',
            'location_id_for_on_call': ENV['LOCATION_ID']&.to_i,
            'position_id_for_on_call': ENV['POSITION_ID']&.to_i,
            'clock_in_time': clock_time.in_time,
            'clock_out_time': clock_time.out_time,
            'tags': [
              'past_attendance',
            ],
            'note': '출퇴근기록 수정 및 생성',
          },
        }.to_json
      end
    end
  end
end
