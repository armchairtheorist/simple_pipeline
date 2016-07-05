class SimplePipeline
    module Timeout
        def self.included (base)
            base.extend(ClassMethods)
            base.class_variable_set(:@@timeout_in_sec, 0)
        end

        module ClassMethods
            def set_timeout (sec)
                self.class_variable_set(:@@timeout_in_sec, sec)
            end
        end

        def timeout=(sec)
            @timeout_in_sec = sec
        end

        def timeout
            @timeout_in_sec || self.class.class_variable_get(:@@timeout_in_sec)
        end
    end
end