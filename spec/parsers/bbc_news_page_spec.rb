$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'spec/base_parser_spec'
require 'web-page-parser'
include WebPageParser

describe BbcNewsPageParserFactory do
  before do
    @valid_urls = [
                   "http://news.bbc.co.uk/1/hi/entertainment/6984082.stm",
                   "http://news.bbc.co.uk/1/hi/northern_ireland/7996478.stm",
                   "http://news.bbc.co.uk/1/hi/uk/7995652.stm",
                   "http://news.bbc.co.uk/1/hi/england/derbyshire/7996494.stm",
                   "http://news.bbc.co.uk/2/low/uk_news/england/devon/7996447.stm",
                   "http://www.bbc.co.uk/news/business-11125504",
                   "http://www.bbc.co.uk/news/10604897"
                  ]
    @invalid_urls = [
                     "http://news.bbc.co.uk/2/hi/health/default.stm",
                     "http://news.bbc.co.uk/2/low/europe/default.stm",
                     "http://news.bbc.co.uk/2/hi/in_pictures/default.stm",
                     "http://news.bbc.co.uk/sport",
                     "http://news.bbc.co.uk/sport1/hi/tennis/8951357.stm",
                     "http://newsforums.bbc.co.uk/nol/thread.jspa?forumID=6422&edition=1&ttl=20090509133749",
                     "http://www.bbc.co.uk/blogs/nickrobinson/",
                     "http://news.bbc.co.uk/hi/english/static/in_depth/health/2000/heart_disease/default.stm",
                     "http://news.bbc.co.uk/1/shared/spl/hi/pop_ups/08/middle_east_views_on_netanyahu0s_us_visit/html/1.stm",
                     "http://www.bbc.co.uk/blogs/theeditors/",
                     "http://www.bbc.co.uk/news/have_your_say/",
                     "http://news.bbc.co.uk/1/hi/magazine/default.stm",
                     "http://news.bbc.co.uk/1/hi/in_pictures/default.stm"
                    ]
  end

  it "should detect bbc news articles from the url" do
    @valid_urls.each do |url|
      BbcNewsPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      BbcNewsPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
  it "should ignore 'in pictures' articles" do
    BbcNewsPageParserFactory.can_parse?(:url => 'http://news.bbc.co.uk/1/hi/in_pictures/8039882.stm').should be_nil
  end
end

describe BbcNewsPageParserV4 do
  it_should_behave_like AllPageParsers
  before do
    @valid_options = { 
      :url => 'http://www.bbc.co.uk/news/business-11125504',
      :page => File.read("spec/fixtures/bbc_news/11125504.html"),
      :valid_hash => 'd9e201abec3f4b9e38865b5135281978'
    }
    @pa = BbcNewsPageParserV4.new(@valid_options)
  end

  it "should parse the title" do
    @pa.title.should == "UK economy 'to pick up in near term'"
  end

  it "should parse the content" do
    @pa.content[0].should == "The British Chambers of Commerce (BCC) has upgraded its forecast for the UK's short term economic prospects, but said interest rates must be kept low to aid recovery."
    @pa.content.last.should == '"Failure to get this right poses the biggest risk to recovery."'
    @pa.content.size.should == 18
  end

end


describe BbcNewsPageParserV3 do
  it_should_behave_like AllPageParsers
  before do
    @valid_options = { 
      :url => 'http://news.bbc.co.uk/1/hi/england/10249066.stm',
      :page => File.read("spec/fixtures/bbc_news/10249066.stm.html"),
      :valid_hash => 'd9e201abec3f4b9e38865b5135281978'
    }
    @pa = BbcNewsPageParserV3.new(@valid_options)
  end

  it "should parse the content" do
    @pa.content[0].should == 'The family of gunman Derrick Bird say they have no idea why he carried out the "horrific" shootings in Cumbria.'
    @pa.content.last.should == '"We appreciate what they are suffering at this time. We cannot offer any reason why Derrick took it upon himself to commit these crimes."'
    @pa.content.size.should == 24    
  end

  it "should parse the content of an article with two captions" do
    @pa = BbcNewsPageParserV3.new({ :url => "http://news.bbc.co.uk/1/hi/politics/10341015.stm", 
                                    :page => File.read("spec/fixtures/bbc_news/10341015.stm.html"),
                                    :valid_hash => 'unknown'
                                  })
    @pa.content[0].should == "The coalition government has cancelled 12 projects totalling £2bn agreed to by the previous Labour government since the start of 2010."
    @pa.content[1].should == "These include an £80m loan to Sheffield Forgemasters and new programmes for the young unemployed, Chief Secretary to the Treasury Danny Alexander told MPs."
    @pa.content[2].should == 'Mr Alexander said the cuts were necessary to tackle the budget deficit and would be done in a "fair" way.'
  end
    

  
end

describe BbcNewsPageParserV2 do
  it_should_behave_like AllPageParsers
  before do
    @valid_options = { 
      :url => 'http://news.bbc.co.uk/1/hi/world/middle_east/8011268.stm',
      :page => File.read("spec/fixtures/bbc_news/8011268.stm.html"),
      :valid_hash => 'd9e201abec3f4b9e38865b5135281978'
    }
    @pa = BbcNewsPageParserV2.new(@valid_options)
  end

  it "should parse the title" do
    @pa.title.should == "Obama invites Middle East heads"
  end
  
  it "should convert iso-8859-1 in the title to utf8" do
    page = BbcNewsPageParserV2.new(:page => '<meta name="Headline" content="'+"\243"+'100K mortgage claim by Woodward"')
    page.title.should == "£100K mortgage claim by Woodward"
  end
  
  it "should convert iso-8859-1 in the content to utf8" do
    page = BbcNewsPageParserV2.new(:page => "S BO -->\243100K mortgage claim by Woodward<!-- E BO")
    page.content.first.should == "£100K mortgage claim by Woodward"
  end
  

  it "should parse the date in UTC" do
    # 2009/04/21 19:50:44
    @pa.date.should == DateTime.parse("Apr 21 19:50:44 +0000 2009")
    @pa.date.zone.should == '+00:00'
  end
  
  it "should parse the content" do
    @pa.content[0].should == "US officials say the leaders of Israel, Egypt and the Palestinians have been invited for talks in Washington in a new push for Middle East peace."
    @pa.content.last.should == "The US supports a two-state solution, with Israel existing peacefully alongside a Palestinian state."
    @pa.content.size.should == 15
  end

  it "should decode html entities" do
    @pa.content[8].should == 'He added: "We are actively working to finalise dates for the visits."'
  end

  it "should calculate a valid hash of the content" do
    @pa.hash.should == @valid_options[:valid_hash]
  end
  
  it "should parse 'from our own correspondent' pages" do
    page = BbcNewsPageParserV2.new(:url => "http://news.bbc.co.uk/1/hi/programmes/from_our_own_correspondent/8029015.stm",
                                   :page => File.read("spec/fixtures/bbc_news/8029015.stm.html"))
    page.title.should == "Cairo's terrifying traffic chaos"
    page.content.first.should == "Christian Fraser discovers that a brush with death on Cairo's congested roads leaves no appetite for life in the fast lane."
  end
  
  it "should parse 'magazine' pages" do
    page = BbcNewsPageParserV2.new(:url => "http://news.bbc.co.uk/1/hi/magazine/8063681.stm",
                                   :page => File.read("spec/fixtures/bbc_news/8063681.stm.html"))
    page.title.should == "My night with Parisien prostitutes"
    page.content.first.should == "Wandering around the red light district of Paris as a teenager taught me all I need to know - about teenagers, not women, says Laurie Taylor in his weekly column."
  end

end

describe BbcNewsPageParserV1 do
  before do
    @valid_options = { 
      :url => 'http://news.bbc.co.uk/1/hi/england/bradford/6072486.stm',
      :page => File.read("spec/fixtures/bbc_news/6072486.stm.html"),
      :valid_hash => 'aaf7ed1219eb69c3126ea5d0774fbe7d'
    }
    @pa = BbcNewsPageParserV1.new(@valid_options)
  end

  it "should parse the title" do
    @pa.title.should == "Son-in-law remanded over killing"
  end

  it "should parse the date in UTC" do
    @pa.date.should == DateTime.parse("Sat Oct 21 14:41:10 +0000 2006")
    @pa.date.zone.should == '+00:00'
  end

  it "should parse the content exactly like the old News Sniffer library" do
    @pa.content.first.should == "<B>The son-in-law of a 73-year-old Castleford widow has been charged with her murder.</B>"
    @pa.content.last.should == 'He denied the charges against him through his solicitor and is due to appear at Leeds Crown Court on Friday.'
    @pa.content.size.should == 5
    @pa.hash.should == @valid_options[:valid_hash]
  end

  it "should convert apostrophe and pound sign html entities in content" do
    @pa = BbcNewsPageParserV1.new :page => 'S SF -->John&apos;s code sucks &amp; blows<!-- E BO'
    @pa.content.to_s.should match Regexp.new("John's")
    @pa.content.to_s.should match /sucks & blows/
  end

  it "should convert apostrophe and pound sign html entities in page titles" do
    @pa = BbcNewsPageParserV1.new :page => '<meta name="Headline" content="John&apos;s code sucks &amp; blows!"/>'
    @pa.title.should match Regexp.new("John's")
    @pa.title.should match /sucks & blows/
  end
  
end
