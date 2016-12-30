# -*- coding: utf-8 -*-
require 'spec_helper'
include WebPageParser

describe GuardianPageParserFactory do
  before do
    @valid_urls = [
                   "http://www.guardian.co.uk/business/2012/jan/27/anger-grows-rbs-chiefs-bonus",
                   "http://www.guardian.co.uk/commentisfree/2012/jan/27/ian-jack-battle-for-scotland",
                   "http://www.guardian.co.uk/environment/bike-blog/2012/jan/27/hgv-cyclists-safety-bike-blog",
                   "http://www.guardian.co.uk/tv-and-radio/2012/jan/26/well-take-manhattan-david-bailey",
                   "http://www.theguardian.com/world/2013/aug/24/syria-cameron-obama-intervention",
                   "http://www.theguardian.com/commentisfree/2013/aug/25/coalition-leaders-change-tune-rawnsley",
                   "http://www.theguardian.com/uk-news/2013/aug/25/police-officer-cleared-taser-brighton"
                  ]
    @invalid_urls = [
                     "http://www.guardian.co.uk/business",
                     "http://www.guardian.co.uk/mobile/apps",
                     "http://www.guardian.co.uk/business/nils-pratley-on-finance",
                     "http://www.guardian.co.uk/commentisfree/commentisfree+uk/uk",
                     "http://www.guardian.co.uk/help/feeds",
                     "http://www.guardian.co.uk/uk/cartoon/2012/jan/28/nicolas-sarkozy-caricature",
                     "http://www.guardian.co.uk/commentisfree/poll/2012/jan/30/smacking-children-david-lammy",
                     "http://www.guardian.co.uk/uk/video/2012/may/13/occupy-protesters-clash-police-video",
                     "http://www.guardian.co.uk/uk/gallery/2012/may/10/public-sector-protests-in-pictures",
                     "http://www.guardian.co.uk/media/video/2012/may/24/chris-huhne-partner-privacy-case-video",
                     "http://www.guardian.co.uk/business/poll/2012/may/09/greek-exit-euro-inevitable",
                     "http://www.theguardian.com/global-development",
                     "http://www.theguardian.com/uk/business"
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

  describe "when parsing the anger-grows article" do
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

  describe "when parsing the syria-libya-middle-east article" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/world/middle-east-live/2011/jun/22/syria-libya-middle-east-unrest-live?INTCMP=ILCNETTXT3487',
        :page => File.read("spec/fixtures/guardian/syria-libya-middle-east-unrest-live.html"),
        :valid_hash => '19427d70638b8d787a004f31ede29757'
      }
      @pa = GuardianPageParserV1.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Bahrain, Syria and Middle East unrest - Wednesday 22 June 2011"
    end

    it "should parse the content" do
      @pa.content[0].should == "9.31am:Welcome to Middle East Live. There's so much happening across the region that it's difficult to know which stories to watch today. Here's a run down of the latest developments by country:"
      @pa.content[1].should == "Bahrain"
      @pa.content[6].should == "When I see children being killed, I must have misgivings. That's why I warned about the risk of civilian casualties... You can't have a decisive ending. Now is the time to do whatever we can to reach a political solution."
      @pa.content.last.should == "(That's it from us today. Thanks for your comments)."
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end



  describe "when parsing the barack obama-nicki-minaj article" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/music/2012/oct/16/barack-obama-nicki-minaj-mariah-carey',
        :page => File.read("spec/fixtures/guardian/barack-obama-nicki-minaj-mariah-carey.html"),
        :valid_hash => '22fe55dc3664662ac6c1c79eac584754'
      }
      @pa = GuardianPageParserV1.new(@valid_options)
    end

    it "should not include +explainerText+" do
      @pa.hash.should == @valid_options[:valid_hash]
      @pa.content.to_s.should_not =~ /explainerText/
    end
  end

  describe "when parsing the anger-grows article with the explainerText javascript" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/business/2012/jan/27/anger-grows-rbs-chiefs-bonus',
        :page => File.read("spec/fixtures/guardian/anger-grows-rbs-chiefs-bonus-with-explainer.html"),
        :valid_hash => '04108a9a7e3196da185e4d10432740a1'
      }
      @pa = GuardianPageParserV1.new(@valid_options)
    end

    it "should have the same hash as before" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should not include +explainerText+" do
      @pa.content.to_s.should_not =~ /explainerText/
    end
  end
end

describe GuardianPageParserV2 do

  describe "when parsing the anger-grows article" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/business/2012/jan/27/anger-grows-rbs-chiefs-bonus',
        :page => File.read("spec/fixtures/guardian/anger-grows-rbs-chiefs-bonus.html"),
        :valid_hash => '04108a9a7e3196da185e4d10432740a1'
      }
      @pa = GuardianPageParserV2.new(@valid_options)
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

  describe "when parsing the syria-libya-middle-east article" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/world/middle-east-live/2011/jun/22/syria-libya-middle-east-unrest-live?INTCMP=ILCNETTXT3487',
        :page => File.read("spec/fixtures/guardian/syria-libya-middle-east-unrest-live.html"),
        :valid_hash => 'a2ed6d79e1fd834df80e2d603b36be22' # changed from V1 due to html stripping
      }
      @pa = GuardianPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Bahrain, Syria and Middle East unrest - Wednesday 22 June 2011"
    end

    it "should parse the content" do
      @pa.content[0].should == "9.31am:Welcome to Middle East Live. There's so much happening across the region that it's difficult to know which stories to watch today. Here's a run down of the latest developments by country:"
      @pa.content[1].should == "Bahrain"
      @pa.content[6].should == "When I see children being killed, I must have misgivings. That's why I warned about the risk of civilian casualties... You can't have a decisive ending. Now is the time to do whatever we can to reach a political solution."
      @pa.content.last.should == "(That's it from us today. Thanks for your comments)."
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end

  describe "when parsing the barack obama-nicki-minaj article" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/music/2012/oct/16/barack-obama-nicki-minaj-mariah-carey',
        :page => File.read("spec/fixtures/guardian/barack-obama-nicki-minaj-mariah-carey.html"),
        :valid_hash => '22fe55dc3664662ac6c1c79eac584754'
      }
      @pa = GuardianPageParserV2.new(@valid_options)
    end

    it "should not include +explainerText+" do
      @pa.hash.should == @valid_options[:valid_hash]
      @pa.content.to_s.should_not =~ /explainerText/
    end
  end

  describe "when parsing the anger-grows article with the explainerText javascript" do
    before do
      @valid_options = { 
        :url => 'http://www.guardian.co.uk/business/2012/jan/27/anger-grows-rbs-chiefs-bonus',
        :page => File.read("spec/fixtures/guardian/anger-grows-rbs-chiefs-bonus-with-explainer.html"),
        :valid_hash => '04108a9a7e3196da185e4d10432740a1'
      }
      @pa = GuardianPageParserV2.new(@valid_options)
    end

    it "should have the same hash as before" do
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it "should not include +explainerText+" do
      @pa.content.to_s.should_not =~ /explainerText/
    end
  end

  describe "when parsing the nhs-patient-data article" do
    before do
      @valid_options = { 
        :url => 'http://www.theguardian.com/society/2014/jan/19/nhs-patient-data-available-companies-buy',
        :page => File.read('spec/fixtures/guardian/nhs-patient-data-available-companies-buy.html'),
        :valid_hash => '0ae4a335bfd96ee3345350814f1e9f97'
      }
      @pa = GuardianPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == 'NHS patient data to be made available for sale to drug and insurance companies'
    end

    it "should parse the content" do
      @pa.content[0].should == 'Drug and insurance companies will from later this year be able to buy information on patients including mental health conditions and diseases such as cancer, as well as smoking and drinking habits, once a single English database of medical data has been created.'
      @pa.content.last.should == 'A spokesperson said: "A phased rollout of care.data is being readied over a three month period with first extractions  from March allowing time for the HSCIC to assess the quality of the data and the linkage before making the data available. We think it would be wrong to exclude private companies simply on ideological grounds; instead, the test should be how the company wants to use the data to improve NHS care."'
      @pa.content.size.should == 21
      @pa.hash.should == @valid_options[:valid_hash]
    end
  end

  describe "when parsing the new format university extremist speakers article" do
    before do
      @valid_options = { 
        :url => 'http://www.theguardian.com/uk-news/2015/mar/20/theresa-may-drops-rules-ordering-universities-ban-extremist-speakers',
        :page => File.read("spec/fixtures/guardian/university-extremist-speakers.html"),
        :valid_hash => 'aeeb32a7acd2de155be83fd7de6446cb'
      }
      @pa = GuardianPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Theresa May drops rules on ordering universities to ban extremist speakers"
    end

    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("Friday 20 March 2015 17:38:30 GMT")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == "The home secretary, Theresa May, has been forced to drop new statutory rules under which ministers could order universities and colleges to ban external extremist speakers."
      @pa.content.size.should == 19
      @pa.hash.should == @valid_options[:valid_hash]
    end

  end

  describe "when parsing the Julian Assange article" do
    before do
      @valid_options = {
        :url => 'https://www.theguardian.com/media/2016/dec/24/julian-assange-donald-trump-hillary-clinton-interview',
        :page => File.read("spec/fixtures/guardian/julian-assange-donald-trump-hillary-clinton-interview.html"),
        :valid_hash => '2757835e9e028a21b5e47c9199ade005'
      }
      @pa = GuardianPageParserV2.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Julian Assange gives guarded praise of Trump and blasts Clinton in interview"
    end

    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("Saturday 24 December 2016 18:36:24 GMT")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == "Julian Assange, the founder of WikiLeaks, has offered guarded praise of Donald Trump, arguing the president-elect “is not a DC insider” and could mean an opportunity for positive as well as negative change in the US."
      @pa.content.last.should == "Dozens of journalists have been killed in Russia in the past two decades, and Freedom House considers the Russian press to be “not free” and notes: “The main national news agenda is firmly controlled by the Kremlin. The government sets editorial policy at state-owned television stations, which dominate the media landscape and generate propagandistic content.”"
      @pa.content.size.should == 16
      @pa.hash.should == @valid_options[:valid_hash]
    end

  end

  describe GuardianPageParserV3 do
    describe "when parsing the Julian Assange article" do
    before do
      @valid_options = {
        :url => 'https://www.theguardian.com/media/2016/dec/24/julian-assange-donald-trump-hillary-clinton-interview',
        :page => File.read("spec/fixtures/guardian/julian-assange-donald-trump-hillary-clinton-interview.html"),
        :valid_hash => 'a94b1cfb7abab286ab4e880e3c440d66'
      }
      @pa = GuardianPageParserV3.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should == "Julian Assange gives guarded praise of Trump and blasts Clinton in interview"
    end

    it "should parse the date in UTC" do
      @pa.date.should == DateTime.parse("Saturday 24 December 2016 18:36:24 GMT")
      @pa.date.zone.should == '+00:00'
    end

    it "should parse the content" do
      @pa.content[0].should == "Julian Assange, the founder of WikiLeaks, has offered guarded praise of Donald Trump, arguing the president-elect “is not a DC insider” and could mean an opportunity for positive as well as negative change in the US."
      @pa.content.last.should == "This article was amended on 29 December 2016 to remove a sentence in which it was asserted that Assange “has long had a close relationship with the Putin regime”. A sentence was also amended which paraphrased the interview, suggesting Assange said “there was no need for Wikileaks to undertake a whistleblowing role in Russia because of the open and competitive debate he claimed exists there”. It has been amended to more directly describe the question Assange was responding to when he spoke of Russia’s “many vibrant publications”."
      @pa.content.size.should == 17
      @pa.hash.should == @valid_options[:valid_hash]
    end

  end

  end

end
