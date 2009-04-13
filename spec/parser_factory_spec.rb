$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'web-page-parser'
include WebPageParser

describe ParserFactory do
  it "should know about its subclasses" do
    ParserFactory.factories.size.should == 0
    class TestParserFactory < ParserFactory ; end
    ParserFactory.factories.size.should == 1
  end
end
