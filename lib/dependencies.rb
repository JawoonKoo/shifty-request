# frozen_string_literal: true

require_relative 'ShiftyRequest/Extend/time'
require_relative 'ShiftyRequest/Extend/date_util'

require_relative 'ShiftyRequest/Model/attendance'
require_relative 'ShiftyRequest/Model/clock_time'
require_relative 'ShiftyRequest/Model/working_time'
require_relative 'ShiftyRequest/Model/create_attendance'
require_relative 'ShiftyRequest/Model/edit_attendance'

require_relative 'ShiftyRequest/Request/api_request'
require_relative 'ShiftyRequest/Request/create_attendance'
require_relative 'ShiftyRequest/Request/edit_attendance'
require_relative 'ShiftyRequest/Request/load_attendance'

require_relative 'ShiftyRequest/Service/make_attendance_service'

require_relative 'ShiftyRequest/command'
