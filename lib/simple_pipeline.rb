require "simple_pipeline/timeout"
require "simple_pipeline/version"


class SimplePipeline

    attr_reader :errors

    def initialize
        @pipe_order = []
        @pipe_config = {}
        @errors = []
    end

    def add (pipe, args = {})
        begin
            raise ArgumentError, "invalid pipe - incorrect number of arguments for process() method (should be 1)" unless pipe.class.instance_method(:process).arity == 1
        rescue NameError
            raise ArgumentError, "invalid pipe - process() method not found"
        end

        @pipe_order << pipe
        @pipe_config[pipe] = args

        return pipe
    end

    def size
        return @pipe_order.size
    end

    def process (payload)
        @pipe_order.each do |pipe|
            begin
                timeout = @pipe_config[pipe][:timeout]

                if timeout.nil? && (pipe.is_a? SimplePipeline::Timeout)
                    timeout = pipe.timeout
                end

                if timeout.nil?
                    pipe.process(payload)
                else
                    process_with_timeout(pipe, payload, timeout)                    
                end
            rescue
                raise $! unless continue_on_error?($!, @pipe_config[pipe][:continue_on_error?])
                @errors << $!
            end
        end
    end

    alias :length :size

    private

    def continue_on_error? (e, config_value)
        return false if config_value.nil? || config_value == false
        return true if config_value == true
        
        if (config_value.is_a? Class) && (e.is_a? config_value)
            return true
        end

        if config_value.is_a? Array
            config_value.each { |klass| return true if (klass.is_a? Class) && (e.is_a? klass) }
        end

        return false
    end


    def process_with_timeout (pipe, payload, timeout)
        ::Timeout::timeout(timeout) {
            pipe.process(payload)
        }
    end
end