# -*- coding: utf-8 -*-
require 'spec_helper'
require 'net/http'
include WebPageParser

describe IndependentPageParserFactory do
  before do
    @valid_urls = [
                   'http://www.independent.co.uk/news/world/saudi-authorities-stop-textmessage-tracking-of-women-for-now-9065486.html?somequery=string',
                   'http://www.independent.co.uk/news/media/tv-radio/the-vex-factor-bbc-produces-almost-identical-programmes-to-those-by-itv-mps-are-told--by-itv-9059695.html',
                  ]
    @invalid_urls = [
                     'http://www.independent.co.uk/sport/rugby/rugby-union/',
                     'http://www.independent.co.uk/news/business/',
                     'http://www.independent.co.uk/news/pictures/spencer-tunicks-nude-art-installations-9067645.html',
                     'http://www.independent.co.uk/sport/rugby/rugby-union/international/chris-robshaw-flanker-answers-all-the-questions-about-red-rose-captaincy-9065632.html'
                    ]
  end

  it "should detect independent articles from the url" do
    @valid_urls.each do |url|
      IndependentPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      IndependentPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end


describe IndependentPageParserV1 do
  describe "when parsing the Saudi authorities article" do
    before do
      @valid_options = { 
        :url => 'www.independent.co.uk/news/world/saudi-authorities-stop-textmessage-tracking-of-women-for-now-9065486.html',
        :page => File.read("spec/fixtures/independent/saudi-authorities-stop-textmessage-tracking-of-women-for-now-9065486.html"),
        :valid_hash => 'cfc2994d68b1c59e10bf3225ae557d31'
      }
      @pa = IndependentPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Saudi authorities stop text-message tracking of women… for now"
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse("Jan 16 2014")
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == "A monitoring system which sends text alerts to Saudi women’s male 'guardians' when they cross the border has been temporarily suspended."
      @pa.content[3].should == 'Many Saudi women have welcomed the freeze of the measure, including Sabria S. Jawhar, a Saudi columnist and assistant professor of applied linguistics at King Saud bin Abdulaziz University for Health Sciences.'
      @pa.content.size.should == 11
    end

    it "should parse the guid" do
      @pa.guid_from_url.should == '9065486'
    end
  end

  describe "when parsing the syria article" do
    before do
      @valid_options = { 
        :url => 'http://www.independent.co.uk/news/world/middle-east/innocent-starving-close-to-death-one-victim-of-the-siege-that-shames-syria-9065538.html',
        :page => File.read('spec/fixtures/independent/innocent-starving-close-to-death-one-victim-of-the-siege-that-shames-syria-9065538.html'),
        :valid_hash => 'bb552f44352d9807bc0299e5d12f6f0e'
      }
      @pa = IndependentPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Innocent, starving, close to death: One victim of the siege that shames Syria"
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse('Jan 16 2014')
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == "Israa al-Masri was still a toddler when she lost her battle to cling to life. But the image of her face, pictured just minutes before she finally succumbed to starvation, is becoming the symbol of a wider nightmare."
      @pa.content.last.should == 'Given the weight of evidence of extreme hunger within Yarmouk, there is no particular reason to doubt the authenticity of other images such as the one above, which is also taken from footage supplied by an activist group, and featured by Al Jazeera. But despite rigorous checks, there is still no sure way of verifying them.'
      @pa.content.size.should == 37
    end
  end

  describe "when parsing the belgian-man article" do
    before do
      @valid_options = { 
        :url => 'http://www.independent.co.uk/news/world/europe/belgian-man-who-skipped-100-restaurant-bills-is-killed-9081407.html',
        :page => File.read('spec/fixtures/independent/belgian-man-who-skipped-100-restaurant-bills-is-killed-9081407.html'),
        :valid_hash => '8e7ca0b6a3c3de210c743a36cea05990'
      }
      @pa = IndependentPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Belgian man who skipped 100 restaurant bills is killed'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse('Jan 23 2014')
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'He was a “happy-go-lucky” guy who was notorious for spicing up life on benefits in the medieval Belgian town of Ghent by strolling into a restaurant, calmly ordering lobster washed down with the finest brandy or some other gastronomic delight and then walking out without paying the bill.'
      @pa.content[1].should == 'But, after 100 or so incidents spread over a five-year spree, Titus Clarysse has turned up dead, prompting police to launch an investigation of “murder or manslaughter”.'
      @pa.content.size.should == 19
    end
  end

  describe 'when parsing the uk-sanctuary article' do
    before do
      @valid_options = { 
        :url => 'http://www.independent.co.uk/news/uk/politics/david-cameron-set-for-uturn-over-uk-sanctuary-for-most-vulnerable-syria-refugees-following-aid-agencies-plea-9077647.html',
        :page => File.read('spec/fixtures/independent/david-cameron-set-for-uturn-over-uk-sanctuary-9077647.html'),
        :valid_hash => '37a6522307cea4fbae37b8eb52191c1d'
      }
      @pa = IndependentPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'David Cameron set for U-turn over UK sanctuary for most vulnerable Syria refugees following plea by aid agencies'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse('Jan 23 2014')
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'David Cameron opened the door yesterday for Britain to give sanctuary to some of the most vulnerable Syrian refugees trapped in appalling conditions in neighbouring countries.'
      @pa.content.join(' ').should_not =~ /brightcove/
      @pa.content.size.should == 16
    end
  end

  describe 'when parsing the lord-burns article' do
    before do
      @valid_options = { 
        :url => 'http://www.independent.co.uk/news/media/lord-burns-channel-4-chairman-forced-to-step-down-by-ministers-amid-privatisation-fears-a6670691.html',
        :page => File.read('spec/fixtures/independent/lord-burns.html'),
        :valid_hash => 'f0efb3b2ea91266fe4a551867fcf6fb1'
      }
      @pa = IndependentPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'Lord Burns: Channel 4 chairman forced to step down by ministers amid privatisation fears'
    end

    it "should parse the date" do
      @pa.date.should == DateTime.parse('28 September 2015 18:03:52 BST')
    end

    it "should calculate the hash correctly" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should == 'Ministers have forced Lord Burns, the chairman of Channel 4, to step down, fuelling speculation that the not-for-profit broadcaster is being prepared for privatisation.'
      @pa.content.size.should == 6
    end
  end

end
