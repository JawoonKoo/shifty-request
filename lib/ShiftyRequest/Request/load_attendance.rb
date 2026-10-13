# frozen_string_literal: true

require 'date'

module ShiftyRequest
  module Request
    class LoadAttendance < APIRequest
      def url
        super + '/batch'
      end

      def request(edit_month:)
        response = HTTParty.post(url, headers: headers, body: body(edit_month:).to_json)

        if auth_error?(response:)
          raise Exception.new("인증 토큰에 문제가 있습니다. .env 파일의 COOKIE 설정을 확인해주세요.\n(서버 응답: #{response.body})")
        end

        parse_response_body(body: JSON.parse(response.body))
      end

      private

      def auth_error?(response:)
        body = response.body
        return false unless body.is_a?(String)

        body.include?('ExpiredAuthToken') || body.include?('NoAuthToken')
      end

      def parse_response_body(body:)
        attendances = body['attendances']
        attendances.filter do |attendance|
          attendance['clock_in_time'].present? && attendance['clock_out_time'].present?
        end.map do |attendance|
          Model::Attendance.new(attendance.transform_keys(&:to_sym))
        end.compact
      end

      def body(edit_month:)
        {
          'attendances': {
            'date_ranges': [[
              edit_month.beginning_of_month.iso8601,
              edit_month.end_of_month.iso8601,
            ]],
            'employee_ids': [ENV['EMPLOYEE_ID'].to_i],
          },
        }
      end
    end
  end
end
