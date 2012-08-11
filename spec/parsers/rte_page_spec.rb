# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'spec/base_parser_spec'
require 'web-page-parser'
include WebPageParser

describe RtePageParserFactory do
  before do
    @valid_urls = [
                   "http://www.rte.ie/news/2012/0718/aer-lingus-repeats-call-to-reject-ryanair-offer-business.html"
                  ]
    @invalid_urls = [
                     "http://www.rte.ie/gaa"
                    ]
  end

  it "should detect rte articles from the url" do
    @valid_urls.each do |url|
      RtePageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      RtePageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end


describe RtePageParserV1 do

  describe "when parsing the ryanair article" do
    before do
      @valid_options = { 
        :url => 'http://www.rte.ie/news/2012/0718/aer-lingus-repeats-call-to-reject-ryanair-offer-business.html',
        :page => File.read("spec/fixtures/rte/aer-lingus-repeats-call-to-reject-ryanair-offer-business.html"),
        :valid_hash => '803be530c7c3360d136b73e5531e9083'
      }
      @pa = RtePageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Aer Lingus repeats call to reject Ryanair offer"
    end
    
    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("2012-07-18T10:28:38")
      @pa.date.zone.should == '+00:00'
    end


    it "should parse the content" do
      @pa.content[1].should == "Aer Lingus has issued a statement this morning calling on shareholders to reject Ryanair's offer."

      @pa.content[2].should == "The company will be writing to shareholders in the next 14 days to set out in detail its reasons for rejecting the offer."
      @pa.content[9].should == "Ryanair is seeking acceptance of the bid by 13 September."
      @pa.content.last.should == "An investigation is also being carried out into Ryanair's current holding by the UK Competition Commission."
      @pa.content.size.should == 11         
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end
end
