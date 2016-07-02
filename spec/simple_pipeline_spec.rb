require 'spec_helper'

class TestPipe
	def process (payload)
		payload[:test_value] *= 10
	end
end

class BadPipe
	def process (payload1, payload2)
		# do nothing
	end
end

class TimeoutPipe
	include SimplePipeline::Timeout

	def initialize
		set_timeout 1 # seconds
	end

	def process (payload)
		sleep 10 # seconds
	end
end

describe SimplePipeline do
	it "should support three normal pipes" do
		pipeline = SimplePipeline.new
		pipeline.add TestPipe.new
		pipeline.add TestPipe.new
		pipeline.add TestPipe.new
		
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
			pipeline.add BadPipe
		}.to raise_error(ArgumentError)
	end

	it "should support pipes with timeout" do
		pipeline = SimplePipeline.new
		pipe = TimeoutPipe.new
		pipeline.add pipe

		expect {
			pipeline.process({})
		}.to raise_error(Timeout::Error)
	end
end