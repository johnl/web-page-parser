# -*- coding: utf-8 -*-
require 'spec_helper'
include WebPageParser

describe WashingtonPostPageParserFactory do
  before do
    @valid_urls = [
                   'http://www.washingtonpost.com/world/will-a-bust-follow-the-boom-in-britain/2014/01/18/3677a6ae-7f9d-11e3-97d3-b9925ce2c57b_story.html?tid=hpModule_04941f10-8a79-11e2-98d9-3012c1cd8d1e&hpid=z16',
                   'http://www.washingtonpost.com/business/technology/nsa-program-defenders-question-snowdens-motives/2014/01/19/091fccaa-811d-11e3-bbe5-6a2a3141e3a9_story.html'
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

end
