# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whatsapp/api/version'

Gem::Specification.new do |gem|
  gem.name        = 'whatsapp-api'
  gem.version     = Whatsapp::Api::VERSION
  gem.authors     = ['Karol Sarnacki']
  gem.email       = ['sodercober@gmail.com']
  gem.description = %q{Ruby Client for the WhatsApp API}
  gem.summary     = %q{Ruby Client for the WhatsApp API}
  gem.homepage    = 'https://github.com/karolsarnacki/whatsapp-api'
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'ruby-rc4'
  gem.add_runtime_dependency 'pbkdf2'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest', '>= 4.4.0'
  gem.add_development_dependency 'simplecov', '>= 0.7.1'
end
