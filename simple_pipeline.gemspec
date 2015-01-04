require File.expand_path("../lib/simple_pipeline/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "simple_pipeline"
  spec.version       = SimplePipeline::VERSION
  spec.authors       = ["Jonathan Wong"]
  spec.email         = ["jonathan@armchairtheorist.com"]
  spec.summary       = "Simple implementation of a configurable processing pipeline framework for sequential execution of reusable code components."
  spec.homepage      = "http://github.com/armchairtheorist/simple_pipeline"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*.rb"]
  spec.require_paths = ["lib"]
end