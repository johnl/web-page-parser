# -*- coding: utf-8 -*-
require 'spec_helper'
require 'net/http'
include WebPageParser

describe NewYorkTimesPageParserFactory do
  before do
    @valid_urls = [
                   "http://www.nytimes.com/2012/01/28/us/politics/no-more-nice-guys-fans-love-nuclear-newt.html?_r=1&ref=us",
                   "http://www.nytimes.com/2012/01/29/business/global/greece-in-talks-with-creditors-on-debt-deal.html",
                  ]
    @invalid_urls = [
                     "http://cityroom.blogs.nytimes.com/2012/01/27/the-week-in-pictures-for-jan-27/",
                     "http://www.nytimes.com/pages/world/asia/index.html"
                    ]
  end

  it "should detect new york times articles from the url" do
    @valid_urls.each do |url|
      NewYorkTimesPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      NewYorkTimesPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end


describe NewYorkTimesPageParserV1 do
  describe "when parsing the Gingrich article" do
    before do
      @valid_options = { 
        :url => 'http://www.nytimes.com/2012/01/27/us/politics/the-long-run-gingrich-stuck-to-caustic-path-in-ethics-battles.html?src=me&ref=general',
        :page => File.read("spec/fixtures/new_york_times/the-long-run-gingrich-stuck-to-caustic-path-in-ethics-battles.html"),
        :valid_hash => '7562feadc3db5c9a4c474cc0e9db421a'
      }
      @pa = NewYorkTimesPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Gingrich Stuck to Caustic Path in Ethics Battles"
    end
    
    it "should parse the date" do
      @pa.date.should == DateTime.parse("Sat Jan 26 2012")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == "WASHINGTON — Newt Gingrich had an urgent warning for conservatives: Jim Wright, the Democratic speaker of the House, was out to destroy America."
      @pa.content[4].should == "Mr. Gingrich, Democrats and Republicans here agree, emerged as one of Washington’s most aggressive practitioners of slash-and-burn politics; many fault him for erasing whatever civility once existed in the capital. He believed, and preached, that harsh language could win elections; in 1990, the political action committee he ran, Gopac, instructed Republican candidates to learn to “speak like Newt,” and offered a list of words to describe Democrats — like decay, traitors, radical, sick, destroy, pathetic, corrupt and shame."
      @pa.content.size.should == 48
    end
  end

  describe "when parsing the hamas-leader article" do
    before do
      @valid_options = { 
        :url => 'http://www.nytimes.com/2012/01/28/world/middleeast/khaled-meshal-the-leader-of-hamas-vacates-damascus.html',
        :page => File.read("spec/fixtures/new_york_times/khaled-meshal-the-leader-of-hamas-vacates-damascus.html"),
        :valid_hash => '99ae48e19224402890b380019ca5fbda'
      }
      @pa = NewYorkTimesPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Hamas Leader Abandons Longtime Base in Damascus"
    end
    
    it "should parse the date" do
      @pa.date.should == DateTime.parse("Fri Jan 27 2012")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == "GAZA — Khaled Meshal, the leader of the Palestinian Islamist movement Hamas, has effectively abandoned his longtime base in Syria, where a popular uprising has left thousands dead, and has no plans to return, Hamas sources in Gaza said Friday."
      @pa.content[4].should == %Q{On Sunday, Mr. Meshal is scheduled to make his first official visit to Jordan since he was deported in 1999. Qatar, one of Mr. Assad’s most vocal Arab critics, played mediator in arranging for Mr. Meshal’s visit to Jordan, which is expected to include a meeting with King Abdullah II. Jordan was the first Arab country to urge Mr. Assad to step down.}
      @pa.content.last.should == "Ethan Bronner contributed reporting from Jerusalem."
      @pa.content.size.should == 7
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end
end

describe NewYorkTimesPageParserV2 do
  describe "when parsing the Gingrich article" do
    before do
      @valid_options = { 
        :url => 'http://www.nytimes.com/2012/01/27/us/politics/the-long-run-gingrich-stuck-to-caustic-path-in-ethics-battles.html?src=me&ref=general',
        :page => File.read("spec/fixtures/new_york_times/the-long-run-gingrich-stuck-to-caustic-path-in-ethics-battles.html"),
        :valid_hash => '7562feadc3db5c9a4c474cc0e9db421a'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Gingrich Stuck to Caustic Path in Ethics Battles"
    end
    
    it "should parse the date" do
      @pa.date.should == DateTime.parse("Sat Jan 26 2012")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == "WASHINGTON — Newt Gingrich had an urgent warning for conservatives: Jim Wright, the Democratic speaker of the House, was out to destroy America."
      @pa.content[4].should == "Mr. Gingrich, Democrats and Republicans here agree, emerged as one of Washington’s most aggressive practitioners of slash-and-burn politics; many fault him for erasing whatever civility once existed in the capital. He believed, and preached, that harsh language could win elections; in 1990, the political action committee he ran, Gopac, instructed Republican candidates to learn to “speak like Newt,” and offered a list of words to describe Democrats — like decay, traitors, radical, sick, destroy, pathetic, corrupt and shame."
      @pa.content.size.should == 48
    end
  end

  describe "when parsing the French comedian article" do
    before do
      @valid_options = { 
        :url => 'http://www.nytimes.com/2014/01/12/world/europe/show-banned-french-comedian-has-new-one.html',
        :page => File.read('spec/fixtures/new_york_times/show-banned-french-comedian-has-new-one.html'),
        :valid_hash => 'ab9cafaac593c12b5b457a5bfdd3eda5'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Show Banned, French Comedian Has New One'
    end
    
    it "should parse the date" do
      @pa.date.should == DateTime.parse("Jan 12th 2014")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'PARIS — A French comedian said Saturday that he had dropped a show banned for its anti-Semitic language and was planning one that would cause no objections.'
      @pa.content[3].should == '“We live in a democratic country and I have to comply with the laws, despite the blatant political interference,” he said. “As a comedian, I have pushed the debate to the very edge of laughter.”'
      @pa.content.size.should == 18
    end
  end


  describe "retrieve_page" do
    it "should retrieve the article from the nyt website" do
      @pa = NewYorkTimesPageParserV2.new(:url => "http://www.nytimes.com/2012/08/22/us/politics/ignoring-calls-to-quit-akin-appeals-to-voters-in-ad.html?hp")
      @pa.title.should =~ /ignoring/i
    end

    it "should retrieve the full article from the nyt website when given a first page url" do
      @pa = NewYorkTimesPageParserV2.new(:url => "http://www.nytimes.com/2012/08/21/world/middleeast/syrian-rebels-coalesce-into-a-fighting-force.html?ref=world")
      @pa.content.size.should > 40
      @pa = NewYorkTimesPageParserV2.new(:url => "http://www.nytimes.com/2012/08/21/world/middleeast/syrian-rebels-coalesce-into-a-fighting-force.html")
      @pa.content.size.should > 40
    end

    it "should retrieve more than the paywall url limit" do
      urls = []
      [
       "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
       "http://rss.nytimes.com/services/xml/rss/nyt/GlobalHome.xml",
       "http://rss.nytimes.com/services/xml/rss/nyt/NYRegion.xml",
       "http://www.nytimes.com/services/xml/rss/nyt/World.xml"
      ].each do |fu|
        next if urls.size > 25
        urls += Net::HTTP.get(URI(fu)).scan(/http:\/\/www.nytimes.com\/[0-9]{4}\/[^<"?]+/)
        urls.uniq!
      end

      urls.size.should > 25
      urls[0..24].each_with_index do |u,i|
        @pa = NewYorkTimesPageParserV2.new(:url => u)
        @pa.page.curl.header_str.to_s.scan(/^Location: .*/).grep(/myaccount.nytimes.com/).should be_empty
        @pa.title.should_not =~ /^Log In/
      end
    end

  end

end
