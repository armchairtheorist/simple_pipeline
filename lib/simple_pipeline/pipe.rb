module SimplePipeline

	class Pipe

		DEFAULT_OPTIONS = {}

		def initialize (options = {})
			@options = DEFAULT_OPTIONS.merge(options)
			@sections = []
		end

		def add (section)
			begin
				raise ArgumentError, "invalid section - incorrect number of arguments for process() method (should be 1)" unless section.class.instance_method(:process).arity == 1
			rescue NameError
				raise ArgumentError, "invalid section - process() method not found"
			end

			@sections << section
		end

		def size
			return @sections.size
		end

		def process (payload)
			@sections.each do |section|
				section.process(payload)
			end
		end

		alias :length :size
	end

end
