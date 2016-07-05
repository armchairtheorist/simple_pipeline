require 'spec_helper'

class TestPipe1
    def process (payload)
        payload[:test_value] *= 10
    end
end

class TestPipe2
    def process (payload1, payload2)
        # do nothing
    end

    def alternate_process_method (payload)
        payload[:test_value] *= 10
    end
end

class TimeoutPipe1
    include SimplePipeline::Timeout

    set_timeout 3 # seconds

    def process (payload)
        sleep 10 # seconds
    end
end

class TimeoutPipe2
    def process (payload)
        sleep 10 # seconds
    end
end

class ExceptionPipe
    def process (payload)
        raise ArgumentError.new "Something bad happened"
    end
end

class ValidationPipe
    include SimplePipeline::Validation

    validate ->(payload) { payload[:must_exist] }
    validate ->(payload) { payload[:must_be_false] == false }
    validate ->(payload) { payload[:a][:b] == 1 }

    def process (payload)
        payload[:test_value] *= 10
    end
end

describe SimplePipeline do
    it "should support three normal pipes" do
        pipeline = SimplePipeline.new
        pipeline.add TestPipe1.new
        pipeline.add TestPipe1.new
        pipeline.add TestPipe1.new
        
        payload = {:test_value => 10}

        pipeline.process(payload)

        expect(pipeline.size).to eq 3
        expect(payload[:test_value]).to eq 10000
    end

    it "should throw an error for invalid pipes" do
        pipeline = SimplePipeline.new
        
        expect {
            pipeline.add Object.new # not a pipe
        }.to raise_error(ArgumentError)

        expect {
            pipeline.add TestPipe2.new
        }.to raise_error(ArgumentError)
    end

    it "should support pipes with timeout values" do
        pipeline = SimplePipeline.new
        pipe = TimeoutPipe1.new
        pipeline.add pipe

        expect(pipe.timeout).to eq 3
        pipe.timeout = 1
        expect(pipe.timeout).to eq 1

        expect {
            pipeline.process({})
        }.to raise_error(Timeout::Error)

        pipeline = SimplePipeline.new
        pipeline.add TimeoutPipe2.new, :timeout => 1

        expect {
            pipeline.process({})
        }.to raise_error(Timeout::Error)
    end

    it "should support pipes with :continue_on_error" do
        pipeline = SimplePipeline.new
        pipeline.add TestPipe1.new
        pipeline.add ExceptionPipe.new
        pipeline.add TestPipe1.new

        payload = {:test_value => 10}

        expect {
            pipeline.process(payload)
        }.to raise_error(ArgumentError)

        expect(payload[:test_value]).to eq 100
        expect(pipeline.errors.size).to eq 0

        pipeline = SimplePipeline.new
        pipeline.add TestPipe1.new
        pipeline.add ExceptionPipe.new, :continue_on_error? => true
        pipeline.add ExceptionPipe.new, :continue_on_error? => ArgumentError
        pipeline.add ExceptionPipe.new, :continue_on_error? => StandardError
        pipeline.add ExceptionPipe.new, :continue_on_error? => [ArgumentError]
        pipeline.add ExceptionPipe.new, :continue_on_error? => [RuntimeError, StandardError]
        pipeline.add TestPipe1.new

        payload = {:test_value => 10}

        pipeline.process(payload)

        expect(payload[:test_value]).to eq 1000
        expect(pipeline.errors.size).to eq 5
    end

    it "should support pipes with :process_method" do
        pipeline = SimplePipeline.new
        pipeline.add TestPipe2.new, :process_method => :alternate_process_method
        
        expect {
            pipeline.add TestPipe1.new, :process_method => :this_method_doesnt_exist
        }.to raise_error(ArgumentError)

        payload = {:test_value => 10}

        pipeline.process(payload)

        expect(payload[:test_value]).to eq 100
    end

    it "should support pipes with payload validation" do
        pipeline = SimplePipeline.new
        pipeline.add ValidationPipe.new

        payload = {:test_value => 10}

        expect {
            pipeline.process(payload)
        }.to raise_error(SimplePipeline::Validation::Error)

        payload = {
            :test_value => 10,
            :must_exist => "abc",
            :must_be_false => false,
            :a => {:b => 1}
        }

        pipeline.process(payload)
        
        expect(payload[:test_value]).to eq 100
    end
end