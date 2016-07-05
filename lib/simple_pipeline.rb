require "simple_pipeline/timeout"
require "simple_pipeline/validation"
require "simple_pipeline/version"


class SimplePipeline

    attr_reader :errors

    def initialize
        @pipe_order = []
        @pipe_options = {}
        @errors = []
    end

    def add (pipe, options = {})
        process_method = options[:process_method] || :process 

        begin
            raise ArgumentError, "invalid pipe - incorrect number of arguments for #{process_method}() method (should be 1)" unless pipe.class.instance_method(process_method).arity == 1
        rescue NameError
            raise ArgumentError, "invalid pipe - #{process_method}() method not found"
        end

        @pipe_order << pipe
        @pipe_options[pipe] = options

        return pipe
    end

    def size
        return @pipe_order.size
    end

    def process (payload)
        @errors.clear

        @pipe_order.each do |pipe|
            begin
                validate_payload(pipe, payload)
                invoke_process_with_timeout(pipe, payload, get_timeout(pipe))
            rescue
                raise $! unless continue_on_error?($!, pipe)
                @errors << $!
            end
        end
    end

    alias :length :size

    private

    def continue_on_error? (e, pipe)
        config_value = @pipe_options[pipe][:continue_on_error?]

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

    def invoke_process_with_timeout (pipe, payload, timeout)
        ::Timeout::timeout(timeout) {
            pipe.__send__(get_process_method(pipe), payload)
        }
    end

    def get_process_method (pipe)
        @pipe_options[pipe][:process_method] || :process
    end

    def get_timeout (pipe)
        timeout = @pipe_options[pipe][:timeout]
        timeout = pipe.timeout if timeout.nil? && (pipe.is_a? SimplePipeline::Timeout)
        return timeout 
    end

    def validate_payload (pipe, payload)
       pipe.validate(payload) if (pipe.is_a? SimplePipeline::Validation) 
    end
end