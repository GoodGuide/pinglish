# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = 'goodguide-pinglish'
  gem.version       = '1.2.1'
  gem.authors       = ['John Barnette', 'Will Farrington', 'Ryan Long']
  gem.email         = ['jbarnette@github.com', 'wfarr@github.com', 'ryan@rtlong.com']
  gem.description   = 'A simple Rack middleware for checking app health.'
  gem.summary       = '/_ping your way to freedom.'
  gem.homepage      = 'https://github.com/goodguide/pinglish'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(/^test/)
  gem.require_paths = ['lib']

  gem.add_dependency 'rack'
  gem.add_development_dependency 'rake', '~> 10.4.0'
  gem.add_development_dependency 'minitest', '~> 4.5'
  gem.add_development_dependency 'rack-test', '~> 0.6'
end
