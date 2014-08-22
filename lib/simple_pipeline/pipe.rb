module SimplePipeline

	class Pipe

		DEFAULT_OPTIONS = {}

		def initialize (options = {})
			@options = DEFAULT_OPTIONS.merge(options)
			@steps = {}
			@step_order = []
		end

		def add (step, label = nil)
			begin
				raise ArgumentError, "incorrect number of arguments for process (payload) method on step" unless step.class.instance_method(:process).arity == 1
			rescue NameError
				raise ArgumentError, "process (payload) method not found on step"
			end

			step_label = nil

			if label.nil?
				next_count = size + 1 
				step_label = "#{step.class.to_s}_#{next_count}"
			else
				step_label = label.to_s
				raise ArgumentError, "step label '#{step_label}' already used" if @steps.has_key?(step_label)
			end

			@steps[step_label] = step
			@step_order << step_label

			return step_label
		end

		def size
			return @step_order.size
		end
		
	end

end
