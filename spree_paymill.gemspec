# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_paymill'
  s.version     = '1.3.1'
  s.summary     = 'Spree extension for using the Paymill payment service'
  s.description = 'This extension adds credit card payments via the payment provider paymill (see paymill.com) to spree'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'webionate GmbH'
  s.email     = 'info@webionate.de'
  s.homepage  = 'http://www.webionate.de'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.3.1'
  s.add_dependency 'paymill'

  s.add_development_dependency 'capybara', '~> 1.1.2'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'sqlite3'
end
