[![Gem Version](https://badge.fury.io/rb/simple_pipeline.svg)](https://badge.fury.io/rb/simple_pipeline)

# SimplePipeline

**SimplePipeline** is a simple framework for sequentially executing a series of code components. Each code component takes a payload, modifies it, and moves it down the pipe for the next component and so forth. One of the design goals is to make it as flexible as possible, yet keep it simple.

## Installation

Install the gem from RubyGems:

```bash
gem install simple_pipeline
```

If you use Bundler, just add it to your Gemfile and run `bundle install`

```ruby
gem 'simple_pipeline'
```

I have only tested this gem on Ruby 2.3.0, but there shouldn't be any reason why it wouldn't work on earlier Ruby versions as well.

## Usage

```ruby
pipeline = SimplePipeline.new

pipeline.add Pipe1.new
pipeline.add Pipe2.new
pipeline.add Pipe3.new
        
payload = {:some_key => some_value}

pipeline.process payload
```

**SimplePipeline** will call the ```process``` method on each of the pipes in the order that they were added to the pipeline. As long as the pipes don't maintain state, you can call ```SimplePipeline#process``` as many times as you want, potentially with each run working with a different payload object.

## Pipes

A **pipe** can be any Ruby object that has a ```process``` method that accepts a single argument (the payload object). For example:

```ruby
class Pipe1
    def process (payload)
        # Do something with the payload object
    end
end
```

If your object does not have a ```process``` method, you can still use it as a pipe, but you will need to explicitly state the method to invoke when adding the pipe to the pipeline. Likewise, the specified method must accept a single payload argument.

```ruby
class AlternatePipe
    def execute (input)
        # Do something with the input
    end
    
    def invoke (param1, param2)
        # Do something else
    end
end

pipeline.add AlternativePipe.new, :process_method => :execute # => OK

pipeline.add AlternativePipe.new, :process_method => :invoke # => throws ArgumentError
```

## Payload

The **payload** can be an Array, Hash, or any other Ruby object. Individual pipes have the responsibility to know what to do with the payload that is passed into the ```process``` method.

**SimplePipeline** supports an easy way to validate the contents of the current payload prior to the execution of a pipe. You can use the ```SimplePipeline::Validation``` mixin and specify validation rules via lambdas, which will be checked prior to processing the pipe. If any of the validation rules fail (i.e. the lambda returns false or raises an error), a ```SimplePipeline::Validation::Error``` will be raised.

```ruby
class ValidatedPipe
    include SimplePipeline::Validation

    validate ->(x) { x[:a] }            # x[:a] must exist 
    validate ->(x) { x[:b] == 1 }       # x[:b] must be equal to 1 
    validate ->(x) { x[:c].nil? }       # x[:c] must not exist
    validate ->(x) { x[:d][:e] < 5 }    # You can even do complex things like this

    def process (payload)
        # Do something
    end
end

pipeline = SimplePipeline.new
pipeline.add ValidatedPipe.new

payload = {:a => some_value}

# Will throw a SimplePipeline::Validation::Error because not all validation rules are satisfied
pipeline.process payload
```

## Timeout

You can use the ```SimplePipeline::Timeout``` mixin to enforce a timeout value (in seconds) for a pipe. If the execution of the ```process``` method exceeds the specified timeout value, a ```Timeout::Error``` will be thrown.

```ruby
class TimeoutPipe
    include SimplePipeline::Timeout

    # Set the timeout value to be 3 seconds
    set_timeout 3 

    def process (payload)
        # Do something
    end
end

pipeline = SimplePipeline.new
pipeline.add TimeoutPipe.new

payload = {:some_key => some_value}

# Will throw a Timeout::Error if execution of process on the TimeoutPipe instance takes longer than 3 seconds
pipeline.process payload
```

You can also set the timeout value on a per instance basis. This will override the timeout value set by the class definition.

```ruby
pipe1 = TimeoutPipe.new
pipe1.set_timeout 10 # seconds

pipe2 = TimeoutPipe.new
pipe2.set_timeout 60 # seconds

pipeline.add pipe1
pipeline.add pipe2
```

If you don't want to use the **SimplePipeline::Timeout** mixin for your pipe, you can still set a timeout by passing in a ```:timeout``` value when you are adding the pipe. If you do this, the param value will take precedence over any other timeout value set by the mixin.

```ruby
# Timeout value set to 10 seconds, even though SomePipe doesn't include SimplePipeline::Timeout
pipeline.add SomePipe.new, :timeout => 10 

# Timeout value set to 10 seconds, even though TimeoutPipe defaults to a timeout of 3 seconds
pipeline.add TimeoutPipe.new, :timeout => 10 
```

## Exception Handling

By default, execution of the entire pipeline will halt if any of the pipes raise a ```StandardError```. However, this can be overriden using the ```:continue_on_error?``` parameter.

```ruby
# Pipeline continues executing if any kind of StandardError is encountered
pipeline.add pipe, :continue_on_error? => true

# Pipeline continues executing if NameError or subclass (e.g. NoMethodError) is encountered
pipeline.add pipe, :continue_on_error? => NameError

# Pipeline continues executing on either ArgumentError or NameError (or subclass)
pipeline.add pipe, :continue_on_error? => [ArgumentError, NameError]

# Pipeline continues executing if any kind of Exception is encountered - not recommended
pipeline.add pipe, :continue_on_error? => Exception
```

After the pipeline finishes executing, you can call ```SimplePipeline#errors``` to get an Array of errors that were caught during execution. This Array will clear itself if the pipeline is run again.

```ruby
pipeline.errors # => Array of errors caught during last run
```

## Related Projects

* [PiecePipe](https://github.com/atomicobject/piece_pipe), an alternative implementation of the pipeline pattern.

## License
**SimplePipeline** is released under the [MIT license](MIT-LICENSE).
