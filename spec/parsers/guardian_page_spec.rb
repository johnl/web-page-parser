# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'spec/base_parser_spec'
require 'web-page-parser'
include WebPageParser

describe GuardianPageParserFactory do
  before do
    @valid_urls = [
                   "http://www.guardian.co.uk/business/2012/jan/27/anger-grows-rbs-chiefs-bonus",
                   "http://www.guardian.co.uk/commentisfree/2012/jan/27/ian-jack-battle-for-scotland",
                   "http://www.guardian.co.uk/environment/bike-blog/2012/jan/27/hgv-cyclists-safety-bike-blog",
                   "http://www.guardian.co.uk/tv-and-radio/2012/jan/26/well-take-manhattan-david-bailey",
                  ]
    @invalid_urls = [
                     "http://www.guardian.co.uk/business",
                     "http://www.guardian.co.uk/mobile/apps",
                     "http://www.guardian.co.uk/business/nils-pratley-on-finance",
                     "http://www.guardian.co.uk/commentisfree/commentisfree+uk/uk",
                     "http://www.guardian.co.uk/help/feeds"
                    ]
  end

  it "should detect guardian articles from the url" do
    @valid_urls.each do |url|
      GuardianPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      GuardianPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end


describe GuardianPageParserV1 do
  before do
    @valid_options = { 
      :url => 'http://www.guardian.co.uk/business/2012/jan/27/anger-grows-rbs-chiefs-bonus',
      :page => File.read("spec/fixtures/guardian/anger-grows-rbs-chiefs-bonus.html"),
      :valid_hash => '04108a9a7e3196da185e4d10432740a1'
    }
    @pa = GuardianPageParserV1.new(@valid_options)
  end

  it "should parse the title" do
    @pa.title.should == "Anger grows over RBS chief's £900,000 bonus"
  end

  it "should parse the date in UTC" do
    @pa.date.should == DateTime.parse("Fri Jan 27 12:58:53 +0000 2012")
    @pa.date.zone.should == '+00:00'
  end

  it "should parse the content" do
    @pa.content[0].should == "Ed Miliband and Boris Johnson have joined the chorus of criticism over the decision by the Royal Bank of Scotland to award its chief executive a bonus of nearly £1m."
    @pa.content[7].should == 'Speaking from the World Economic Forum in Davos, Switzerland, Johnson described the bonus as "absolutely bewildering" and said it should have been blocked by ministers.'
    @pa.content[38].should == '"Even to be considering this at a time when we are struggling to get our economies growing is quite simply madness," he told leaders in a speech to the World Economic Forum.'
    @pa.content.last.should == "."
    @pa.content.size.should == 40
    @pa.hash.should == @valid_options[:valid_hash]
  end
  
end
