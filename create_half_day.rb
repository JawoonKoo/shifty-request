# frozen_string_literal: true
require 'dotenv/load'
require_relative 'lib/dependencies'

puts '9월 30일 반차 출퇴근 기록 생성을 시작합니다.'

# Set working time for half-day
working_time = ShiftyRequest::Model::WorkingTime.new(
  Time.parse('2026-09-30 14:30:00 +0900'),
  Time.parse('2026-09-30 19:00:00 +0900')
)

date = Date.parse('2026-09-30')
create_attendance = ShiftyRequest::Model::CreateAttendance.new(date)

request_service = ShiftyRequest::Request::CreateAttendance.new
request_service.call(create_attendances: [create_attendance], working_time: working_time)

# 터미널 명령어는 ruby create_half_day.rb