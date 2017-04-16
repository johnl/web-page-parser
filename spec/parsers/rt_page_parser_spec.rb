# -*- coding: utf-8 -*-
require 'spec_helper'
include WebPageParser

describe RTPageParserFactory do
  before do
    @valid_urls = ["https://www.rt.com/uk/338045-privatization-aid-money-dfid/",
                   "https://www.rt.com/business/338032-saudi-arabia-megafund-assets/",
                   "https://www.rt.com/usa/338131-candy-thief-life-sentence/"]
    @invalid_urls = ["https://www.rt.com/politics/",
                     "https://www.rt.com/in-vision/337713-egyptair-hijacker-hostages-free/",
                     "https://www.rt.com/in-motion/338243-anti-refugee-rally-uk/"]
  end

  it "should detect articles from the url" do
    @valid_urls.each do |url|
      RTPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      RTPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end

end

describe RTPageParserV1 do

  describe "when parsing the privatised aid article" do
    before do
      @valid_options = { 
        :url => 'https://www.rt.com/uk/338045-privatization-aid-money-dfid/',
        :page => File.read("spec/fixtures/rt/338045.html"),
        :valid_hash => '067d06dffae315daf6ab88026fdc7966'
      }
      @pa = RTPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "‘Scandal of privatized aid’: Free-market consultants cream off £450mn in UK govt funds"
    end

    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("2016-04-01 15:17")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == "Free-market consultants in Britain are taking hundreds of millions of pounds ring-fenced to alleviate poverty in the developing world, as the government continues with its agenda of privatizing aid, a damning report has warned."
      @pa.content[4].should == "The study examined how much of DfID’s work was geared towards supporting market-based development and the private sector in poor states. Recent projects included backing for a “business advocacy capacity development program” in Zimbabwe, and projects to increase private schooling in Kenya."
      @pa.content[22].should == "ASI describes itself as a transparent, objective organization dedicated to making public services more robust. It also claims to support economic growth and civil society, while building “democratic and accountable institutions.”"
      @pa.content.size.should == 23
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end

  describe "when parsing the trump article" do
    before do
      @valid_options = { 
        :url => 'https://www.rt.com/usa/338237-trump-fine-nato-breakup-obsolete/',
        :page => File.read("spec/fixtures/rt/338237.html"),
        :valid_hash => '633221af5d9b9a7161cd40eaaf22253d'
      }
      @pa = RTPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Trump sparks NATO debate: ‘Obsolete’ or ‘tripwire that could lead to World War III’?"
    end

    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("2016-04-03 11:47")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == "Republican presidential candidate Donald Trump slammed NATO on the campaign trail this week, saying he can live with breaking up the military alliance, which he calls “obsolete.”"
      @pa.content[4].should == "NATO"
      @pa.content[11].should == "The now-28 member-strong organization has defied its purported promise on a number of occasions."
      @pa.content[24].should == "The cost of NATO"
      @pa.content.size.should == 39
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end    
end
