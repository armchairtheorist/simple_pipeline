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

I have only tested this gem on Ruby 2.3, but there shouldn't be any reason why it wouldn't work on earlier Ruby versions as well.

## Usage

TODO: Write usage instructions here

## License
SimplePipeline is released under the [MIT license](MIT-LICENSE).
