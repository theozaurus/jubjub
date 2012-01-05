Gem::Specification.new do |s|
  s.name        = "jubjub"
  s.version     = "0.0.8"
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.author      = "Theo Cushion"
  s.email       = "theo.c@zepler.net"
  s.homepage    = "http://github.com/theozaurus/jubjub"
  s.summary     = "An Object to XMPP mapper to make managing XMPP resources easy"
  s.description = "jubjub is designed to provie a simple API for controller XMPP servers and their resources. Currently it should be used in conjunction with xmpp_gateway, but the architecture has been left so that other backends could be implemented."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency 'nokogiri'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock', '~> 1.6'
  s.add_development_dependency 'rspec', '~> 2.4'
  s.add_development_dependency 'equivalent-xml', '~> 0.2.7'

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.mdown)
  s.test_files   = Dir.glob("spec/**/*") + %w(.rspec .infinity_test)
  s.require_path = 'lib'
end