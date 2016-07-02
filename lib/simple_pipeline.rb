require "simple_pipeline/timeout"
require "simple_pipeline/version"


class SimplePipeline

	def initialize
		@pipes = []
	end

	def add (pipe)
		begin
			raise ArgumentError, "invalid pipe - incorrect number of arguments for process() method (should be 1)" unless pipe.class.instance_method(:process).arity == 1
		rescue NameError
			raise ArgumentError, "invalid pipe - process() method not found"
		end

		@pipes << pipe
	end

	def size
		return @pipes.size
	end

	def process (payload)
		@pipes.each do |pipe|
			if pipe.is_a? SimplePipeline::Timeout
				pipe.process_with_timeout(payload)
			else
				pipe.process(payload)
			end
		end
	end

	alias :length :size

end