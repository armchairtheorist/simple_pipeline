class SimplePipeline
    module Validation
        class Error < StandardError; end

        def self.included (base)
            base.extend(ClassMethods)
            base.class_variable_set(:@@validations, [])
        end

        module ClassMethods
            def validate (validation_lambda)
                raise ArgumentException "invalid validation - expect lambda instead of #{validation_lambda.class}" unless (validation_lambda.is_a? Proc) && validation_lambda.lambda?

                self.class_variable_get(:@@validations) << validation_lambda
            end
        end

        def validate (payload)
            self.class.class_variable_get(:@@validations).each do |validation_lambda|
                begin
                    raise SimplePipeline::Validation::Error.new "#{self.class} - #{payload}" unless validation_lambda.call(payload)
                rescue
                    raise SimplePipeline::Validation::Error.new "#{self.class} - #{payload}"
                end
            end
        end
    end
end