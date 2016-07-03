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

pipeline.process(payload)
```

**SimplePipeline** will call the ```process (payload)``` method on each of the pipes in the order that they were added to the pipeline.

## Pipes

A **pipe** can be any Ruby object that has a ```process (payload)``` method with a single argument.

## Payload

The **payload** can be an Array, Hash, or any other Ruby object. Individual pipes have the responsibility to know what to do with the payload that is passed into the ```process (payload)``` method.

## License
SimplePipeline is released under the [MIT license](MIT-LICENSE).
