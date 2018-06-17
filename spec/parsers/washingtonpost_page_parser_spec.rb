# -*- coding: utf-8 -*-
require 'spec_helper'
include WebPageParser

describe WashingtonPostPageParserFactory do
  before do
    @valid_urls = [
                   'http://www.washingtonpost.com/world/will-a-bust-follow-the-boom-in-britain/2014/01/18/3677a6ae-7f9d-11e3-97d3-b9925ce2c57b_story.html?tid=hpModule_04941f10-8a79-11e2-98d9-3012c1cd8d1e&hpid=z16',
                   'http://www.washingtonpost.com/business/technology/nsa-program-defenders-question-snowdens-motives/2014/01/19/091fccaa-811d-11e3-bbe5-6a2a3141e3a9_story.html',
                   'https://www.washingtonpost.com/world/middle_east/israel-ambassador-to-us-sends-anti-boycott-message-with-gift/2015/12/23/652d639c-a99b-11e5-b596-113f59ee069a_story.html'
                  ]
    @invalid_urls = [
                     'http://www.washingtonpost.com/politics/',
                     'http://www.washingtonpost.com/local/',
                     'http://www.washingtonpost.com/blogs/worldviews/',
                     'http://www.washingtonpost.com/blogs/worldviews/wp/tag/iran/'
                    ]
  end

  it "should detect washpo articles from the url" do
    @valid_urls.each do |url|
      WashingtonPostPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      WashingtonPostPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end

describe WashingtonPostPageParserV1 do

  describe 'when parsing the al-shabab article' do
    before do
      @valid_options = {
                        :url => 'http://www.washingtonpost.com/world/national-security/pentagon-confirms-al-shabab-leader-killed-in-airstrike-in-somalia/2014/09/05/fc9fee06-3512-11e4-9e92-0899b306bbea_story.html',
                        :page => File.read('spec/fixtures/washingtonpost/pentagon-confirms-al-shabab-leader-killed.html'),
                        :valid_hash => 'FIXME'
                       }
      @pa = WashingtonPostPageParserV1.new(@valid_options)
      
    end

    it 'should parse the title' do
      @pa.title.should == 'White House confirms al-Shabab leader killed in airstrike in Somalia'
    end

    it 'should parse the content' do
      @pa.content[0].should == 'In a major setback for al-Qaeda’s affiliate in East Africa, the Obama administration said Friday it had confirmed the death of a key Somali militant leader who had been targeted in an airstrike earlier in the week.'
    end

    it 'should get the guid from the url' do
      @pa.guid_from_url.should == 'fc9fee06-3512-11e4-9e92-0899b306bbea'
    end

    it 'should return the guid from the url using the guid method' do
      @pa.guid.should == 'fc9fee06-3512-11e4-9e92-0899b306bbea'
    end
  end

  describe 'when parsing the bust-boom article' do
    before do
      @valid_options = { 
        :url => 'http://www.washingtonpost.com/world/will-a-bust-follow-the-boom-in-britain/2014/01/18/3677a6ae-7f9d-11e3-97d3-b9925ce2c57b_story.html?tid=hpModule_04941f10-8a79-11e2-98d9-3012c1cd8d1e&hpid=z16',
        :page => File.read('spec/fixtures/washingtonpost/will-a-bust-follow-the-boom-in-britain.html'),
        :valid_hash => '86020be298247aaecfc53e3d66f8c6ee'
      }
      @pa = WashingtonPostPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Will a bust follow the boom in Britain?'
    end
   
    it 'should parse the date in UTC' do
      @pa.date.should == DateTime.parse("January 18th 2014")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == 'LONDON — For decades, the modest two-bedroom apartment off Abbey Road was home to some of London’s neediest, a small, leaky outpost in this city’s vast constellation of public housing.'
      @pa.content[12].should == 'Crazy in the capital'
      @pa.content.last.should == '“It’s about time the government did something to help,” he said. “I don’t come from a rich family, so I don’t have parents who will give 15,000 pounds for a deposit. That’s not available to me. I’m genuinely pleased Cameron has done something for the working man, which is me.”'
      @pa.content.size.should == 25
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end

  describe 'when parsing the sgt bowe article' do
    before do
      @valid_options = { 
        :url => 'http://www.washingtonpost.com/world/national-security/sgt-bowe-bergdahls-capture-remains-amystery/2014/01/15/4f8ef686-7e28-11e3-9556-4a4bf7bcbd84_story.html?wprss=rss_national-security',
        :page => File.read('spec/fixtures/washingtonpost/sgt-bowe-bergdahls-capture-remains-amystery.html'),
        :valid_hash => '1fd07efe6bfbf5c4551e88d09a663e25'
      }
      @pa = WashingtonPostPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Sgt. Bowe Bergdahl’s capture remains a mystery'
    end

    it 'should parse the date in UTC' do
      @pa.date.should == DateTime.parse("January 15th 2014")
      @pa.date.zone.should == '+00:00'
    end

    it "should contain no javascript" do
      @pa.content.join(' ').should_not =~ /function/
    end

    it "should parse the content" do
      @pa.content[0].should == 'Correction: An earlier version of this article misspelled the name of Sgt. Bowe Bergdahl.'
      @pa.content.size.should == 8 # The blockquote ends up as one big paragraph
      @pa.hash.should == @valid_options[:valid_hash]
    end

  end

  describe 'when parsing the Israeli ambassador article' do
    before do
      @valid_options = {
        :url => 'https://www.washingtonpost.com/world/middle_east/israel-ambassador-to-us-sends-anti-boycott-message-with-gift/2015/12/23/652d639c-a99b-11e5-b596-113f59ee069a_story.html',
        :page => File.read('spec/fixtures/washingtonpost/israeli-ambassador.html'),
        :valid_hash => 'c2e80bf1012949bf3a124576466b1b40'
      }
      @pa = WashingtonPostPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq 'Israel ambassador to US sends anti-boycott message with gift'
    end

    it 'should parse the date in UTC' do
      @pa.date.should eq DateTime.parse("December 23 2015")
      @pa.date.zone.should eq '+00:00'
    end

    it "should contain no javascript" do
      @pa.content.join(' ').should_not =~ /function/
    end

    it "should parse the content" do
      @pa.content[0].should eq 'JERUSALEM — Israel’s ambassador to the United States has dispatched a politically charged holiday gift.'
      @pa.content.size.should eq 6
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end
end

describe WashingtonPostPageParserV2 do
  describe 'when parsing the trump kim simmit article' do
    before do
      @valid_options = {
        :url => 'https://www.washingtonpost.com/politics/trump-kim-summit-trump-says-we-have-developed-a-very-special-bond-at-end-of-historic-meeting/2018/06/12/ff43465a-6dba-11e8-bf86-a2351b5ece99_story.html?utm_term=.392b71a75a35',
        :page => File.read('spec/fixtures/washingtonpost/trump-kim-summit.html'),
        :valid_hash => '5b703096157e74b65fdf00fd9227ebbc'
      }
      @pa = WashingtonPostPageParserV2.new(@valid_options)
    end

    it "should parse the guid" do
      @pa.guid.should eq "ff43465a-6dba-11e8-bf86-a2351b5ece99"
    end

    it "should parse the title" do
      @pa.title.should eq 'Trump-Kim summit: Trump says after historic meeting, ‘We have developed a very special bond’'
    end

    it 'should parse the date in UTC' do
      @pa.date.should eq DateTime.parse("2018-06-12T11:47:00-05:00")
    end

    it "should parse the content" do
      @pa.content[0].should eq 'SINGAPORE —  President Trump concluded a historic summit with North Korean leader Kim Jong Un here Tuesday by sketching a path to prosperity for the isolated nation. But it remained highly uncertain whether the young dictator would embrace the offer by agreeing to eliminate his nuclear arsenal.'
      @pa.content.last.should eq 'Carol Morello in Washington and Brian Murphy in Seoul contributed to this report.'
      @pa.content[9].should eq 'Trump said that aides would begin additional talks soon and that he would potentially invite Kim to the White House and be open to visiting Pyongyang “at the appropriate time.” Yet he also acknowledged that disarmament would not come quickly.'
      @pa.content.size.should eq 45
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

    describe 'when parsing the bust-boom article from 2018' do
    before do
      @valid_options = {
        :url => 'https://www.washingtonpost.com/world/will-a-bust-follow-the-boom-in-britain/2014/01/18/3677a6ae-7f9d-11e3-97d3-b9925ce2c57b_story.html?tid=hpModule_04941f10-8a79-11e2-98d9-3012c1cd8d1e&hpid=z16',
        :page => File.read('spec/fixtures/washingtonpost/will-a-bust-follow-the-boom-in-britain-2018.html'),
        :valid_hash => 'bbcdda8a8dffcabf71088039fb366e34'
      }
      @pa = WashingtonPostPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Will a bust follow the boom in Britain?'
    end

    it 'should parse the date in UTC' do
      @pa.date.should eq DateTime.parse("2014-01-18T05:43:00-05:00")
      @pa.date.zone.should eq '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should eq 'LONDON — For decades, the modest two-bedroom apartment off Abbey Road was home to some of London’s neediest, a small, leaky outpost in this city’s vast constellation of public housing.'
      @pa.content[12].should eq 'Crazy in the capital'
      @pa.content.last.should eq '“It’s about time the government did something to help,” he said. “I don’t come from a rich family, so I don’t have parents who will give 15,000 pounds for a deposit. That’s not available to me. I’m genuinely pleased Cameron has done something for the working man, which is me.”'
      @pa.content.size.should eq 25
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

end
