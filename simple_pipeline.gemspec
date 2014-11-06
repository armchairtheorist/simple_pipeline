require File.expand_path("../lib/simple_pipeline/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "simple_pipeline"
  spec.version       = SimplePipeline::VERSION
  spec.authors       = ["Jonathan Wong"]
  spec.email         = ["jonathan@armchairtheorist.com"]
  spec.summary       = "Summary"
  spec.description   = "Description"
  spec.homepage      = "http://github.com/armchairtheorist/simple_pipeline"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end