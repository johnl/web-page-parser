$:.unshift File.join(File.dirname(__FILE__), '../lib')
$:.unshift File.join(File.dirname(__FILE__), '../spec')

require 'web-page-parser'
require 'webmock/rspec'
require 'vcr'

require 'support/vcr'

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
