# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'spec/base_parser_spec'
require 'web-page-parser'
include WebPageParser

describe IrishtimesPageParserFactory do
  before do
    @valid_urls = [
                   "http://www.irishtimes.com/newspaper/finance/2012/0811/1224321990288.html"
                  ]
    @invalid_urls = [
                     "http://www.irishtimes.com/sport"
                    ]
  end

  it "should detect rte articles from the url" do
    @valid_urls.each do |url|
      IrishtimesPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      IrishtimesPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end


describe IrishtimesPageParserV1 do

  describe "when parsing the sample irish times article" do
    before do
      @valid_options = { 
        :url => 'http://www.irishtimes.com/newspaper/finance/2012/0811/1224321990276.html',
        :page => File.read("spec/fixtures/irishtimes/irishtimestest.html"),
        :valid_hash => 'c5915a5ea4f3452b84690366a935fe35'
      }
      @pa = IrishtimesPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Audit exemption to save firms money"
    end
    


    it "should parse the content" do
      @pa.content[1].should == "SMALLER IRISH companies can expect to save up to \342\202\2545 million a year following an increase in the audit exemption limit."
      @pa.content[2].should == "Companies with a turnover of less than \342\202\254 8.8 million, a balance sheet of less than \342\202\254 4.4 million and 50 or fewer employees will no longer have to have their annual accounts prepared by an external auditor."
      @pa.content[9].should == "However, the ACCA notes there is \342\200\234broad agreement\342\200\235 with the Department of Jobs, Enterprise and Innovation to allow small groups to claim audit exemption."
      @pa.content.last.should == "In some cases, this might mean calling an EGM to amend company formation documents."
      @pa.hash.should == @valid_options[:valid_hash]
      
      @pa.content.size == 12
    end
  end
end
