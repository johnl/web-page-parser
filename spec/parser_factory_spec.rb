$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'web-page-parser'
include WebPageParser

describe ParserFactory do

  it "should load parsers in the parsers directory" do
    ParserFactory.factories.first.to_s.should == "TestPageParserFactory"
  end

  it "should provide the right PageParser for the given url" do
    ParserFactory.parser_for("http://www.example.com").should be_a_kind_of TestPageParser
  end
end
