# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_paymill'
  s.version     = '3.0.0'
  s.summary     = 'Spree extension for using the Paymill payment service'
  s.description = 'This extension adds credit card payments via the payment provider paymill (see paymill.com) to spree'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'webionate GmbH'
  s.email     = 'info@webionate.de'
  s.homepage  = 'http://www.webionate.de'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '~> 3.0.0'

  s.add_dependency 'spree_core', spree_version

  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'dotenv-rails'
end
