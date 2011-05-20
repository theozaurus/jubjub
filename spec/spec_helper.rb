$:.unshift File.join(File.dirname(File.dirname(__FILE__)),'lib')

require 'jubjub'
require 'vcr'

Dir[File.join(File.dirname(__FILE__),'support','*.rb')].each{|f| require f }

RSpec.configure do |config|
  config.expect_with :rspec
  config.mock_with   :rspec
  config.extend VCR::RSpec::Macros
end

VCR.config do |config|
  config.cassette_library_dir = File.join(File.dirname(__FILE__),'fixtures','vcr_cassettes')
  config.stub_with :webmock
  config.default_cassette_options = { :record => :none, :match_requests_on => [:uri, :method, :body] }
end

