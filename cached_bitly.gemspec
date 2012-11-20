# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cached_bitly/version'

Gem::Specification.new do |gem|
  gem.name          = 'cached_bitly'
  gem.version       = CachedBitly::VERSION
  gem.authors       = ['Garrett Bjerkhoel']
  gem.email         = ['me@garrettbjerkhoel.com']
  gem.description   = %q{An easy Bitly toolkit with Redis being the caching layer.}
  gem.summary       = %q{An easy Bitly toolkit with Redis being the caching layer.}
  gem.homepage      = 'https://github.com/dewski/cached_bitly'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'redis'
  gem.add_dependency 'bitly', '~> 0.8'
end
