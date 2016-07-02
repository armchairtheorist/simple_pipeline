require 'timeout'

class SimplePipeline

	module Timeout

		def set_timeout (sec)
			@timeout_in_sec = sec
		end

		def process_with_timeout (payload)
			::Timeout::timeout(@timeout_in_sec) {
				process(payload)
			}
		end

	end

end