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

end