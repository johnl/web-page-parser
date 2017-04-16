require 'spec_helper'
include WebPageParser

describe ParserFactory do

  it "should load parsers in the parsers directory" do
    pfl = ParserFactory.factories.collect { |f| f.to_s }
    pfl.should include "TestPageParserFactory"
  end

  it "should provide the right PageParser for the given url" do
    ParserFactory.parser_for(:url => "http://www.example.com").should be_a_kind_of TestPageParser
  end

  it "should return nil if no PageParser can be found for the given url" do
    ParserFactory.parser_for(:url => "http://www.nowhere.nodomain").should be_nil
  end
end
