# -*- coding: utf-8 -*-
require 'spec_helper'
include WebPageParser

describe RTPageParserFactory do
  before do
    @valid_urls = ["https://www.rt.com/uk/338045-privatization-aid-money-dfid/",
                   "https://www.rt.com/business/338032-saudi-arabia-megafund-assets/",
                   "https://www.rt.com/usa/338131-candy-thief-life-sentence/",
                   "https://www.rt.com/news/564427-assange-positive-covid-belmarsh-lockdown/"]
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

describe RTPageParserV2 do
  describe "when parsing the assange article" do
    before do
      @valid_options = {
        :url => 'https://www.rt.com/news/564427-assange-positive-covid-belmarsh-lockdown/',
        :page => File.read("spec/fixtures/rt/564427.html"),
        :valid_hash => 'ac57634d5280556a2009cfb76f21ddbe'
      }
      @pa = RTPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Assange tests positive for Covid-19 in prison"
    end

    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("10 Oct, 2022 17:38")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == "The Wikileaks publisher has been put on 24/7 lockdown in Belmarsh, his wife reports"
      @pa.content[1].should == "Wikileaks founder Julian Assange has tested positive for Covid-19 and is being kept in total isolation at Belmarsh Prison as he continues to fight extradition to the US, his wife Stella told media on Monday."
      @pa.content.last.should == "Assange faces a 175-year sentence on charges he leaked secret documents he received from a US Army analyst regarding the Afghanistan and Iraq wars. Wikileaks supporters have argued that he was only practicing journalism by publishing the documents, which were redacted to remove some sensitive information, and accused Washington of retaliation against the outlet for exposing its own war crimes."
      @pa.content.size.should == 8
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end
end
