# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whatsapp/version'

Gem::Specification.new do |gem|
  gem.name        = 'whatsapp'
  gem.version     = WhatsApp::VERSION
  gem.authors       = ["Trevor Kimenye"]
  gem.email         = ["trevor@sprout.co.ke"]
  gem.summary       = %q{Ruby API to connect to WhatsApp}
  gem.description   = %q{Ruby API to connect to WhatsApp}
  gem.homepage      = "https://github.com/sproutke/whatsapi"
  
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']


  gem.add_runtime_dependency 'httparty', '~> 0.11.0'
  gem.add_runtime_dependency 'httmultiparty', '~> 0.3.10'
  gem.add_runtime_dependency 'pbkdf2-peter_v', '~> 0.1.2'
  gem.add_runtime_dependency 'proxifier', '~> 1.0.3'
  gem.add_runtime_dependency 'ruby-rc4', '~> 0.1.5'

  gem.add_dependency 'activesupport'
  gem.add_development_dependency "bundler", "~> 1.7"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "nyan-cat-formatter"  
end
