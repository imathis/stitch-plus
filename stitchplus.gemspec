# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stitch-plus/version'

Gem::Specification.new do |gem|
  gem.name          = "stitch-plus"
  gem.version       = StitchPlusVersion::VERSION
  gem.authors       = ["Brandon Mathis"]
  gem.email         = ["brandon@imathis.com"]
  gem.description   = %q{A nicer way to combine and uglify javascript with fingerprinting and modularization. Powered by Stitch.}
  gem.summary       = %q{A nicer way to combine and uglify javascript with fingerprinting and modularization. Powered by Stitch.}
  gem.homepage      = "https://github.com/imathis/stitch-plus"
  gem.license       = "MIT"

  gem.add_runtime_dependency 'stitch-rb', '>= 0.0.8'
  gem.add_runtime_dependency 'colorator', '>= 0.1'
  
  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
end
