# -*- coding: utf-8 -*-
require 'spec_helper'
require 'net/http'
include WebPageParser

describe NewYorkTimesPageParserFactory do
  before do
    @valid_urls = [
                   "http://www.nytimes.com/2012/01/28/us/politics/no-more-nice-guys-fans-love-nuclear-newt.html?_r=1&ref=us",
                   "http://www.nytimes.com/2012/01/29/business/global/greece-in-talks-with-creditors-on-debt-deal.html",
                   "https://www.nytimes.com/2014/01/12/world/europe/show-banned-french-comedian-has-new-one.html",
                   "https://www.nytimes.com/2018/06/12/world/asia/trump-kim-policy.html?hp&action=click&pgtype=Homepage&clickSource=story-heading&module=span-ab-top-region&region=top-news&WT.nav=top-news"
                  ]
    @invalid_urls = [
                     "http://cityroom.blogs.nytimes.com/2012/01/27/the-week-in-pictures-for-jan-27/",
                     "http://www.nytimes.com/pages/world/asia/index.html",
                     "https://www.nytimes.com/section/business?module=SectionsNav&action=click&version=BrowseTree&region=TopBar&contentCollection=Business&pgtype=sectionfront",
                     "https://www.nytimes.com/section/technology/personaltech"
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
      @pa.date.should == DateTime.parse("2012-01-27T04:09:35+00:00")
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
      @pa.date.should == DateTime.parse("2014-01-12T05:35:51+00:00")
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

  describe "when parsing the French comedian article with the 2018 formatting" do
    before do
      @valid_options = {
        :url => 'https://www.nytimes.com/2014/01/12/world/europe/show-banned-french-comedian-has-new-one.html',
        :page => File.read('spec/fixtures/new_york_times/show-banned-french-comedian-has-new-one-2018.html'),
        :valid_hash => 'ab9cafaac593c12b5b457a5bfdd3eda5'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Show Banned, French Comedian Has New One'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse("2014-01-12T05:35:51+00:00")
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


  describe "when parsing trump kim policy article" do
    before do
      @valid_options = {
        :url => 'https://www.nytimes.com/2018/06/12/world/asia/trump-kim-policy.html',
        :page => File.read('spec/fixtures/new_york_times/trump-kim-policy.html'),
        :valid_hash => '6149e45ade82fb37973ecb78d3ef774e'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Vague on Details, Trump Is Betting on ‘Special Bond’ With Kim to Deliver Deal'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse("2018-06-12T16:35:00+00:00")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'SINGAPORE — On paper, there is nothing President Trump extracted from North Korea’s leader, Kim Jong-un, in their summit meeting that Mr. Kim’s father and grandfather had not already given to past American presidents.'
      @pa.content[8].should == '“I don’t know that I’ll ever admit that,” he added, “but I’ll find some kind of an excuse.”'
      @pa.content.last.should == "Whatever he gets, it will be judged by one standard: whether he has “solved” the North Korea problem, as he vowed he would, rather than passing it on to his successor."
      @pa.content.size.should == 28
    end
  end

  describe "when teacher union article" do
    before do
      @valid_options = {
        :url => 'https://www.nytimes.com/2020/07/29/us/teacher-union-school-reopening-coronavirus.html',
        :page => File.read('spec/fixtures/new_york_times/teacher-union-school-reopening-coronavirus.html'),
        :valid_hash => '7b15e81d671611707228bddeec644abb'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Teachers Are Wary of Returning to Class, and Online Instruction Too'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse("2020-07-29T18:51:51+00:00")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'As the nation heads toward a chaotic back-to-school season, with officials struggling over when to reopen classrooms and how to engage children online, teachers’ unions are playing a powerful role in determining the shape of public education as the coronavirus pandemic continues to rage.'
      @pa.content[28].should == 'Across the country, it is likely that most students will experience a mix of online and in-person education this academic year, sometimes during the same week. That means teachers will need to do two very different jobs: teach in classrooms and online.'
      @pa.content.last.should == '“I’m excited to go back, if that’s what’s decided,” she said. “I miss my students.”'
      @pa.content.to_s.should_not =~ /Updated Sept. 2, 2020/
      @pa.content.size.should == 47
    end
  end

  describe "convention wraps up article" do
    before do
      @valid_options = {
        :url => 'https://www.nytimes.com/2020/08/27/us/elections/heres-how-to-watch-as-the-convention-wraps-up.html',
        :page => File.read('spec/fixtures/new_york_times/heres-how-to-watch-as-the-convention-wraps-up.html'),
        :valid_hash => '9d816c12e8ba956d33127a8b9912a076'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Here’s how to watch as the convention wraps up.'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse("2020-08-27T15:25:34+00:00")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'After eight intense nights of programming, the 2020 conventions will come to an end on Thursday: President Trump will formally accept the Republican nomination, and the general election season will officially begin.'
      @pa.content[3].should == 'The Times will stream the convention, accompanied by chat-based live analysis from our reporters and real-time speech highlights.'
      @pa.content[8].should == 'Stacia Brightmon, a Marine Corps veteran who participated in an apprenticeship program.'
      @pa.content.to_s.should_not =~ /Maggie Astor is a political reporter based in New York/
      @pa.content.last.should == "Dana White, the president of the Ultimate Fighting Championship."
    end
  end


  describe "retrieve_page" do
    it "should retrieve the article from the nyt website" do
      @pa = NewYorkTimesPageParserV2.new(:url => "http://www.nytimes.com/2012/08/22/us/politics/ignoring-calls-to-quit-akin-appeals-to-voters-in-ad.html?hp")
      @pa.title.should =~ /ignoring/i
    end

    it "should retrieve the full article from the nyt website when given a first page url" do
      pending "currently broken due to needing javascript execution"
      @pa = NewYorkTimesPageParserV2.new(:url => "http://www.nytimes.com/2012/08/21/world/middleeast/syrian-rebels-coalesce-into-a-fighting-force.html?ref=world")
      @pa.content.size.should > 40
      @pa = NewYorkTimesPageParserV2.new(:url => "http://www.nytimes.com/2012/08/21/world/middleeast/syrian-rebels-coalesce-into-a-fighting-force.html")
      @pa.content.size.should > 40
    end

    it "should retrieve more than the paywall url limit" do
      urls = []
      [
       "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
       "https://rss.nytimes.com/services/xml/rss/nyt/GlobalHome.xml",
       "https://rss.nytimes.com/services/xml/rss/nyt/NYRegion.xml",
       "https://www.nytimes.com/services/xml/rss/nyt/World.xml"
      ].each do |fu|
        next if urls.size > 25
        urls += Net::HTTP.get(URI(fu)).scan(/https:\/\/www.nytimes.com\/[0-9]{4}\/[^<"?]+/)
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

  describe "when parsing the ignoring deadlines article from 2021" do
    before do
      @valid_options = {
        :url => 'https://www.nytimes.com/2012/08/22/us/politics/ignoring-calls-to-quit-akin-appeals-to-voters-in-ad.html?hp',
        :page => File.read('spec/fixtures/new_york_times/ignoring-deadlines-2021.html'),
        :valid_hash => '3eb16b452d15d67f1ff004bb5beae43d'
      }
      @pa = NewYorkTimesPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Ignoring Deadline to Quit, G.O.P. Senate Candidate Defies His Party Leaders'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse("Aug. 21, 2012 16:57:37")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should eq 'WASHINGTON — Representative Todd Akin on Tuesday ignored a deadline to abandon Missouri’s Senate race and vowed to remain the Republican nominee in defiance of his party’s leaders, including the presidential standard-bearer, Mitt Romney.'
      @pa.content.last.should eq "Republican Party officials had hoped to push Mr. Akin out by the first deadline, set by Missouri law, at 5 p.m. on Tuesday but it passed with him taking no action. The candidate can still take his name off the ballot up to Sept. 25, but the withdrawal could be contested by Missouri’s secretary of state, a Democrat, or any election authority in the state, even one at the city or county level. That is a fight Republicans want to avoid."
      @pa.content.size.should == 30
    end
  end
end
