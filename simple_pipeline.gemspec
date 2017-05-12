require File.expand_path('../lib/simple_pipeline/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'simple_pipeline'
  spec.version       = SimplePipeline::VERSION
  spec.authors       = ['Jonathan Wong']
  spec.email         = ['jonathan@armchairtheorist.com']
  spec.summary       = 'Simple framework for sequentially executing a series of reusable code components.'
  spec.homepage      = 'https://github.com/armchairtheorist/simple_pipeline'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 0'
  spec.add_development_dependency 'rake', '~> 0'
end
