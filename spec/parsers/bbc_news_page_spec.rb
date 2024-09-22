# -*- coding: utf-8 -*-
$:.unshift File.join(File.dirname(__FILE__), '../../lib')
$:.unshift File.join(File.dirname(__FILE__), '../../spec')
require 'base_parser_spec'
require 'spec_helper'
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
      "http://www.bbc.co.uk/news/10604897",
      "http://www.bbc.co.uk/news/world-middle-east-18229870#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa",
      "http://www.bbc.co.uk/news/election-2015-32271505",
      "https://www.bbc.com/news/articles/cr5n51ym19jo",
      "https://www.bbc.co.uk/news/articles/cr5n51ym19jo"
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
      BbcNewsPageParserFactory.can_parse?(url: url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      BbcNewsPageParserFactory.can_parse?(url: url).should be_nil
    end
  end

  it "should ignore 'in pictures' articles" do
    BbcNewsPageParserFactory.can_parse?(url: 'http://news.bbc.co.uk/1/hi/in_pictures/8039882.stm').should be_nil
  end
end

describe BbcNewsPageParserV7 do

    describe "Dorset man article" do
    before do
      @valid_options = {
        url: 'https://www.bbc.co.uk/news/av/uk-england-dorset-61896381',
        page: File.read("spec/fixtures/bbc_news/61896381.html"),
        valid_hash: 'dc48936e9b6fb25ceec425941a14e440'
      }
      @pa = BbcNewsPageParserV7.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Dorset man Chandy Green calls for disability hate crime awareness"
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should eq 'A man who suffers with mobility problems and has been taunted for the way he walks has said disability discrimination is often overlooked.'
      @pa.content[4].should eq %q(Mr Green said he supported the force's approach and would prefer to see offenders educated rather than punished.)
      @pa.content.last.should eq "Follow BBC South East on Facebook, on Twitter, and on Instagram. Send your story ideas to southeasttoday@bbc.co.uk."
      @pa.content.size.should eq 7
    end

    it "should not include the published date" do
      @pa.content.to_s.should_not =~ /Published/
      @pa.content.to_s.should_not =~ /3 days ago/
    end
  end

  describe "Covid sage article" do
    before do
      @valid_options = {
        url: 'https://www.bbc.co.uk/news/health-54528983',
        page: File.read("spec/fixtures/bbc_news/54528983.html"),
        valid_hash: '198cf66c8f6cc881b235c1e25201f7bb'
      }
      @pa = BbcNewsPageParserV7.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Covid Sage documents: The scientific evidence and what No 10 then did"
    end

    it "should parse the content" do
      @pa.content[0].should eq "New measures announced by Boris Johnson this week fell short of advice provided by scientists"
      @pa.content[1].should eq "Documents have revealed the UK government did not follow the advice given to it by scientists as coronavirus cases began to surge."
      @pa.content[5].should eq "What scientists recommended: They did not go as far as recommending a full lockdown on the scale of the one in the spring. This was also an outcome Prime Minister Boris Johnson has been extremely keen to avoid."
      @pa.content[12].should eq "Going to work"
      @pa.content.last.should eq "TESTING: How do I get a virus test?"
      @pa.content.size.should eq 34
    end

    it "should parse the headers" do
      @pa.content[4].should eq "Full lockdown"
    end

    it "should parse the date" do
      @pa.date.should eq DateTime.parse("October 13 23:44:11 +0000 2020")
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

end

describe BbcNewsPageParserV6 do

    describe "Dorset man article" do
    before do
      @valid_options = {
        url: 'https://www.bbc.co.uk/news/av/uk-england-dorset-61896381',
        page: File.read("spec/fixtures/bbc_news/61896381.html"),
        valid_hash: '574c09f20bac8178344a990b6bd769cc'
      }
      @pa = BbcNewsPageParserV6.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Dorset man Chandy Green calls for disability hate crime awareness"
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[2].should eq 'A man who suffers with mobility problems and has been taunted for the way he walks has said disability discrimination is often overlooked.'
      @pa.content[6].should eq %q(Mr Green said he supported the force's approach and would prefer to see offenders educated rather than punished.)
      @pa.content.size.should eq 9
    end

    it "should not include the published date" do
      @pa.content.to_s.should_not =~ /Published/
      @pa.content.to_s.should_not =~ /3 days ago/
    end
  end

  describe "Inheritance tax plans article" do
    before do
      @valid_options = {
        url: 'http://www.bbc.co.uk/news/election-2015-32271505',
        page: File.read("spec/fixtures/bbc_news/32271505-2020.html"),
        valid_hash: '36298b152e10ba2a5900c45d33aa5467'
      }
      @pa = BbcNewsPageParserV6.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Election 2015: Tory inheritance tax plan 'about values'"
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should eq 'George Osborne: "We believe that your home... should belong to you and your family, not the taxman"'
      @pa.content[1].should eq 'Chancellor George Osborne has said a Conservative plan to remove family homes worth up to £1m from inheritance tax "supports the basic human instinct to provide for your children".'
      @pa.content[8].should eq "Labour has been setting out plans to raise an extra £7.5bn a year through closing tax loopholes and imposing bigger fines on tax avoiders"
      @pa.content.last.should eq %q(However, when asked whether the Lib Dems would block the proposals if they ended up back in coalition, he declined to say he would, instead saying: "I'm saying I strongly disagree with it. Our priority... is further increases in the income tax personal allowance... we've stopped things in this parliament including cuts to inheritance tax for millionaires.")
      @pa.content.size.should eq 37
    end
  end

  describe "Hilary Clinton article" do
    before do
      @valid_options = {
        url: 'http://www.bbc.co.uk/news/world-us-canada-32275608',
        page: File.read("spec/fixtures/bbc_news/32275608-2020.html"),
        valid_hash: '4e91f2a7c24637d9d8d4bd0c690885d4'
      }
      @pa = BbcNewsPageParserV6.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Hillary Clinton declares 2016 Democratic presidential bid"
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should eq %q("I'm running for president," Hillary Clinton declares in an online video)
      @pa.content[1].should eq "Former US Secretary of State Hillary Clinton has formally entered the 2016 race for the White House in a bid to become the first woman US president."
      @pa.content[8].should eq "How it all started for Hillary Clinton"
      @pa.content.last.should eq "Investigated by the State Department for her use of a private email server, circumventing legal requirements"
      @pa.content.size.should eq 38
    end

    it "should parse the headers in the content" do
      @pa.content[14].should eq "Analysis: Gary O'Donoghue, BBC News,  Des Moines, Iowa"
      @pa.content[22].should eq "Is this Hillary Clinton's time?"
    end

    it "should parse the date" do
      @pa.date.should eq DateTime.parse("Apr 12 22:36:19 +0000 2015")
    end
  end

  describe "Covid sage article" do
    before do
      @valid_options = {
        url: 'https://www.bbc.co.uk/news/health-54528983',
        page: File.read("spec/fixtures/bbc_news/54528983.html"),
        valid_hash: '198cf66c8f6cc881b235c1e25201f7bb'
      }
      @pa = BbcNewsPageParserV6.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Covid Sage documents: The scientific evidence and what No 10 then did"
    end

    it "should parse the content" do
      @pa.content[0].should eq "New measures announced by Boris Johnson this week fell short of advice provided by scientists"
      @pa.content[1].should eq "Documents have revealed the UK government did not follow the advice given to it by scientists as coronavirus cases began to surge."
      @pa.content[5].should eq "What scientists recommended: They did not go as far as recommending a full lockdown on the scale of the one in the spring. This was also an outcome Prime Minister Boris Johnson has been extremely keen to avoid."
      @pa.content[12].should eq "Going to work"
      @pa.content.last.should eq "TESTING: How do I get a virus test?"
      @pa.content.size.should eq 34
    end

    it "should parse the headers" do
      @pa.content[4].should eq "Full lockdown"
    end

    it "should parse the date" do
      @pa.date.should eq DateTime.parse("October 13 23:44:11 +0000 2020")
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

  describe "Long Covid article" do
    before do
      @valid_options = {
        url: "https://www.bbc.co.uk/news/health-54622059",
        page: File.read("spec/fixtures/bbc_news/54622059.html")
      }
      @pa = BbcNewsPageParserV6.new(@valid_options)
    end

    it "should not include the Top Stories section" do
      @pa.content.to_s.should_not match("Top Stories")
      @pa.content.to_s.should_not match("Prince William")
    end
  end

  it "should retrieve the article from the bbc website" do
    @pa = BbcNewsPageParserV6.new(url: "http://www.bbc.co.uk/news/business-11125504")
    @pa.title.should eq "UK economy 'to pick up in near term'"
  end
end

describe BbcNewsPageParserV5 do
  describe "downloaded article with non-utf8" do
    page = BbcNewsPageParserV5.new(url: "http://news.bbc.co.uk/1/hi/uk_politics/7984711.stm")
    page.hash.should_not == nil
    page.hash.should_not == ""
  end

  describe "China media article" do
    before do
      @valid_options = {
        url: 'http://www.bbc.co.uk/news/world-asia-china-31014941',
        page: File.read("spec/fixtures/bbc_news/31014941.html")
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should parse without erroring" do
      @pa.title.should eq "China media: Military might"
      @pa.content.size.should > 0
    end
  end

  describe "Oscar Pistorius article" do
    it_should_behave_like AllPageParsers
    before do
      @valid_options = {
        url: 'http://www.bbc.co.uk/news/world-africa-21528631',
        page: File.read("spec/fixtures/bbc_news/21528631.html"),
        valid_hash: '38ef9fc2bbaa5a023a3ada53398b7d95'
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Oscar Pistorius detective on attempted murder charges"
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content.first.should eq "The South African detective leading the Oscar Pistorius inquiry is facing seven charges of attempted murder, police have confirmed."
      @pa.content.last.should eq "In London he made history by becoming the first double-amputee to run in the Olympics, making the semi-final of the 400m."
      @pa.content.should include "Reinstated charges"
      @pa.content.should include "Mr Roux said this was a strong, loving relationship and that there was no motive to kill."
      @pa.content.should include "The three were arrested in 2011, Eyewitness News says, citing police."
      @pa.content.size.should eq 38
    end

    it "should exclude the twitter feed" do
      @pa.content.to_s.should_not =~ /Live tweets/
      @pa.content.to_s.should_not =~ /An old mystery resurfaces/
    end

    it "should parse the publication date" do
      # 2013/02/21 14:10:58
      @pa.date.should eq DateTime.parse("Feb 21 14:10:58 +0000 2013")
    end
  end

  describe "UK economy article" do
    before do
      @valid_options = {
        url: 'http://www.bbc.co.uk/news/business-11125504',
        page: File.read("spec/fixtures/bbc_news/11125504.html"),
        valid_hash: '55d67e013759012f25eea1521bbe962f'
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "UK economy 'to pick up in near term'"
    end

    it "should calculate the right hash" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end

    it "should parse the content" do
      @pa.content[0].should eq "The British Chambers of Commerce (BCC) has upgraded its forecast for the UK's short term economic prospects, but said interest rates must be kept low to aid recovery."
      @pa.content.last.should eq '"Failure to get this right poses the biggest risk to recovery."'
      @pa.content.size.should eq 18
    end
  end

  it "should ignore embedded-hyper content" do
    @pa = BbcNewsPageParserV5.new(page: File.read('spec/fixtures/bbc_news/12921632.html'))
    @pa.content.to_s.should_not =~ /Fake and real quotes/
  end

  it "should parse the content of an article with market data" do
    @pa = BbcNewsPageParserV5.new(page: File.read('spec/fixtures/bbc_news/13293006.html'))
    @pa.content.to_s.should_not =~ /Market Data/
    @pa.content.to_s.should_not =~ /Last updated at/
    @pa.content.size.should eq 13
  end

  it "should ignore the twitter widget" do
    pa = BbcNewsPageParserV5.new(url: "http://www.bbc.co.uk/news/world-us-canada-20230333", page: File.read("spec/fixtures/bbc_news/20230333.stm.html"))
    pa.title.should eq "US election: Results declared from some states"
    pa.content.first.should eq "President Barack Obama and challenger Mitt Romney remain locked in a tight race as US election results stream in."
    pa.content.to_s.should_not =~ /US Election Tweets/
    pa.content.last.should eq "The BBC is providing full online live results of the US presidential election. More details here ."
    pa.content.should include "Legal battles feared"
  end

  it "should ignore the 'latest' twitter widget" do
    pa = BbcNewsPageParserV5.new(url: "http://www.bbc.co.uk/news/uk-19957138", page: File.read("spec/fixtures/bbc_news/19957138.stm.html"))
    pa.title.should eq "Gary McKinnon extradition to US blocked by Theresa May"
    pa.content.to_s.should_not =~ /High Noon for Abu Qatada?/
    pa.content.to_s.should_not =~ /Content from Twitter./
    pa.content.last.should eq "Mr McKinnon was arrested in 2002 and again in 2005 before an order for his extradition was made in July 2006 under the 2003 Extradition Act."
  end

  describe "Derrick Bird article" do
    before do
      @valid_options = {
        url: 'http://news.bbc.co.uk/1/hi/england/10249066.stm',
        page: File.read("spec/fixtures/bbc_news/10249066.stm.html"),
        valid_hash: '43634596a9f1cfb59bb9548282043119' # Differs from V3 as title is obtained more accurately
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Gunman's family unaware of motive for killings"
    end

    it "should parse the content" do
      @pa.content[0].should eq 'The family of gunman Derrick Bird say they have no idea why he carried out the "horrific" shootings in Cumbria.'
      @pa.content.last.should eq '"We appreciate what they are suffering at this time. We cannot offer any reason why Derrick took it upon himself to commit these crimes."'
      @pa.content.size.should eq 24
    end

    it "should parse the publication date" do
      # 2010/06/06 13:48:45
      @pa.date.should eq DateTime.parse("Jun 06 13:48:45 +0000 2010")
    end

    it "should calculate a valid hash of the content" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

  describe "Obama invite article" do
    before do
      @valid_options = {
        url: 'http://news.bbc.co.uk/1/hi/world/middle_east/8011268.stm',
        page: File.read("spec/fixtures/bbc_news/8011268.stm.html"),
        valid_hash: 'd9e201abec3f4b9e38865b5135281978'
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Obama invites Middle East heads"
    end

    it "should parse the date in UTC" do
      # 2009/04/21 19:50:44
      @pa.date.should eq DateTime.parse("Apr 21 19:50:44 +0000 2009")
      @pa.date.zone.should eq '+00:00'
    end

    it "should parse the content" do
      @pa.content.first.should eq "US officials say the leaders of Israel, Egypt and the Palestinians have been invited for talks in Washington in a new push for Middle East peace."
      @pa.content.last.should eq "The US supports a two-state solution, with Israel existing peacefully alongside a Palestinian state."
      @pa.content.size.should eq 15
    end

    it "should decode html entities" do
      @pa.content[8].should eq 'He added: "We are actively working to finalise dates for the visits."'
    end

    it "should calculate a valid hash of the content" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

  describe "Woodward mortgage article" do
    before do
      @valid_options = {
        url: 'http://news.bbc.co.uk/1/hi/northern_ireland/8040164.stm',
        page: File.read("spec/fixtures/bbc_news/8040164.stm.html"),
        valid_hash: 'f2a9ea3dbc8af5065cd8f70d13e35c08'
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should convert iso-8859-1 in the title to utf8" do
      @pa.title.should eq "£100K mortgage claim by Woodward"
    end

    it "should convert iso-8859-1 in the content to utf8" do
      @pa.content.first.should =~ /£100,000/
    end

    it "should calculate a valid hash of the content" do
      @pa.hash.should eq @valid_options[:valid_hash]
    end
  end

  it "should parse the content of an article with two captions" do
    @pa = BbcNewsPageParserV5.new(url: "http://news.bbc.co.uk/1/hi/politics/10341015.stm",
                                  page: File.read("spec/fixtures/bbc_news/10341015.stm.html"),
                                  valid_hash: 'unknown')
    @pa.content[0].should eq "The coalition government has cancelled 12 projects totalling £2bn agreed to by the previous Labour government since the start of 2010."
    @pa.content[1].should eq "These include an £80m loan to Sheffield Forgemasters and new programmes for the young unemployed, Chief Secretary to the Treasury Danny Alexander told MPs."
    @pa.content[2].should eq 'Mr Alexander said the cuts were necessary to tackle the budget deficit and would be done in a "fair" way.'
  end

  describe "Inheritance tax plans article" do
    before do
      @valid_options = {
        url: 'http://www.bbc.co.uk/news/election-2015-32271505',
        page: File.read("spec/fixtures/bbc_news/32271505.html"),
        valid_hash: ''
      }
      @pa = BbcNewsPageParserV5.new(@valid_options)
    end

    it "should parse the title" do
      @pa.title.should eq "Election 2015: Tory inheritance tax plan 'about values'"
    end

    it "should parse the content" do
      @pa.content[0].should eq 'Chancellor George Osborne has said Conservative plans to remove family homes worth up to £1m from inheritance tax "supports the basic human instinct to provide for your children".'
      @pa.content.last.should eq %q(However, when asked whether the Lib Dems would block the proposals if they ended up back in coalition, he declined to say he would, instead saying: "I'm saying I strongly disagree with it. Our priority... is further increases in the income tax personal allowance... we've stopped things in this parliament including cuts to inheritance tax for millionaires.")
      @pa.content.size.should eq 29
    end
  end
end

describe BbcNewsPageParserV4 do
  it_should_behave_like AllPageParsers

  before do
    @valid_options = {
      url: 'http://www.bbc.co.uk/news/business-11125504',
      page: File.read("spec/fixtures/bbc_news/11125504.html"),
      valid_hash: '55d67e013759012f25eea1521bbe962f'
    }
    @pa = BbcNewsPageParserV4.new(@valid_options)
  end

  it "should calculate a valid hash of the content" do
    @pa.hash.should eq @valid_options[:valid_hash]
  end

  it "should parse the title" do
    @pa.title.should eq "UK economy 'to pick up in near term'"
  end

  it "should parse the content" do
    @pa.content[0].should eq "The British Chambers of Commerce (BCC) has upgraded its forecast for the UK's short term economic prospects, but said interest rates must be kept low to aid recovery."
    @pa.content.last.should eq '"Failure to get this right poses the biggest risk to recovery."'
    @pa.content.size.should eq 18
  end

  it "should parse the content of an article with market data" do
    @pa = BbcNewsPageParserV4.new(page: File.read('spec/fixtures/bbc_news/13293006.html'))
    @pa.content.to_s.should_not =~ /Market Data/
    @pa.content.to_s.should_not =~ /Last updated at/
    @pa.content.size.should eq 13
  end

  it "should ignore embedded-hyper content" do
    @pa = BbcNewsPageParserV4.new(page: File.read('spec/fixtures/bbc_news/12921632.html'))
    @pa.content.to_s.should_not =~ /Fake and real quotes/
  end

  it "should ignore the twitter widget" do
    pa = BbcNewsPageParserV4.new(url: "http://www.bbc.co.uk/news/world-us-canada-20230333", page: File.read("spec/fixtures/bbc_news/20230333.stm.html"))
    pa.title.should eq "US election: Results declared from some states"
    pa.content.first.should eq "President Barack Obama and challenger Mitt Romney remain locked in a tight race as US election results stream in."
    pa.content.to_s.should_not =~ /US Election Tweets/
    pa.content.last.should eq "Are you a voter in one of the swing states? Send us your comments on the election campaign using the form below."
  end

  it "should ignore the 'latest' twitter widget" do
    pa = BbcNewsPageParserV4.new(url: "http://www.bbc.co.uk/news/uk-19957138", page: File.read("spec/fixtures/bbc_news/19957138.stm.html"))
    pa.title.should eq "Gary McKinnon extradition to US blocked by Theresa May"
    pa.content.to_s.should_not =~ /High Noon for Abu Qatada?/
    pa.content.to_s.should_not =~ /Content from Twitter./
    pa.content.last.should eq "Mr McKinnon was arrested in 2002 and again in 2005 before an order for his extradition was made in July 2006 under the 2003 Extradition Act."
  end

  it "should retrieve an old iso-8859-1 article without getting upset about encoding" do
    pending "This url is now 404 and I can't find any other iso-8859-1 articles. I think they converted them all to utf8 now"
    @pa = BbcNewsPageParserV4.new(url: "http://www.bbc.co.uk/news/magazine-20761954")
    @pa.title.should eq "Quiz of the Year: 52 weeks 52 questions, part four"
  end
end

describe BbcNewsPageParserV3 do
  it_should_behave_like AllPageParsers
  before do
    @valid_options = {
      url: 'http://news.bbc.co.uk/1/hi/england/10249066.stm',
      page: File.read("spec/fixtures/bbc_news/10249066.stm.html"),
      valid_hash: '764a7db03feb91c66a37d7680e89ee0b'
    }
    @pa = BbcNewsPageParserV3.new(@valid_options)
  end

  it "should calculate a valid hash of the content" do
    @pa.hash.should eq @valid_options[:valid_hash]
  end

  it "should parse the content" do
    @pa.content[0].should eq 'The family of gunman Derrick Bird say they have no idea why he carried out the "horrific" shootings in Cumbria.'
    @pa.content.last.should eq '"We appreciate what they are suffering at this time. We cannot offer any reason why Derrick took it upon himself to commit these crimes."'
    @pa.content.size.should eq 24
  end

  it "should parse the content of an article with two captions" do
    @pa = BbcNewsPageParserV3.new(url: "http://news.bbc.co.uk/1/hi/politics/10341015.stm",
                                  page: File.read("spec/fixtures/bbc_news/10341015.stm.html"),
                                  valid_hash: 'unknown')
    @pa.content[0].should eq "The coalition government has cancelled 12 projects totalling £2bn agreed to by the previous Labour government since the start of 2010."
    @pa.content[1].should eq "These include an £80m loan to Sheffield Forgemasters and new programmes for the young unemployed, Chief Secretary to the Treasury Danny Alexander told MPs."
    @pa.content[2].should eq 'Mr Alexander said the cuts were necessary to tackle the budget deficit and would be done in a "fair" way.'
  end
end

describe BbcNewsPageParserV2 do
  it_should_behave_like AllPageParsers
  before do
    @valid_options = {
      url: 'http://news.bbc.co.uk/1/hi/world/middle_east/8011268.stm',
      page: File.read("spec/fixtures/bbc_news/8011268.stm.html"),
      valid_hash: 'd9e201abec3f4b9e38865b5135281978'
    }
    @pa = BbcNewsPageParserV2.new(@valid_options)
  end

  it "should parse the title" do
    @pa.title.should eq "Obama invites Middle East heads"
  end

  it "should convert iso-8859-1 in the title to utf8" do
    page = BbcNewsPageParserV2.new(page: '<meta name="Headline" content="'+"\243"+'100K mortgage claim by Woodward"')
    page.title.should eq "£100K mortgage claim by Woodward"
  end

  it "should convert iso-8859-1 in the content to utf8" do
    page = BbcNewsPageParserV2.new(page: "S BO -->\243100K mortgage claim by Woodward<!-- E BO")
    page.content.first.should eq "£100K mortgage claim by Woodward"
  end

  it "should parse the date in UTC" do
    # 2009/04/21 19:50:44
    @pa.date.should eq DateTime.parse("Apr 21 19:50:44 +0000 2009")
    @pa.date.zone.should eq '+00:00'
  end

  it "should parse the content" do
    @pa.content[0].should eq "US officials say the leaders of Israel, Egypt and the Palestinians have been invited for talks in Washington in a new push for Middle East peace."
    @pa.content.last.should eq "The US supports a two-state solution, with Israel existing peacefully alongside a Palestinian state."
    @pa.content.size.should eq 15
  end

  it "should decode html entities" do
    @pa.content[8].should eq 'He added: "We are actively working to finalise dates for the visits."'
  end

  it "should calculate a valid hash of the content" do
    @pa.hash.should eq @valid_options[:valid_hash]
  end

  it "should parse 'from our own correspondent' pages" do
    page = BbcNewsPageParserV2.new(url: "http://news.bbc.co.uk/1/hi/programmes/from_our_own_correspondent/8029015.stm",
                                   page: File.read("spec/fixtures/bbc_news/8029015.stm.html"))
    page.title.should eq "Cairo's terrifying traffic chaos"
    page.content.first.should eq "Christian Fraser discovers that a brush with death on Cairo's congested roads leaves no appetite for life in the fast lane."
  end

  it "should parse 'magazine' pages" do
    page = BbcNewsPageParserV2.new(url: "http://news.bbc.co.uk/1/hi/magazine/8063681.stm",
                                   page: File.read("spec/fixtures/bbc_news/8063681.stm.html"))
    page.title.should eq "My night with Parisien prostitutes"
    page.content.first.should eq "Wandering around the red light district of Paris as a teenager taught me all I need to know - about teenagers, not women, says Laurie Taylor in his weekly column."
  end
end

describe BbcNewsPageParserV1 do
  before do
    @valid_options = {
      url: 'http://news.bbc.co.uk/1/hi/england/bradford/6072486.stm',
      page: File.read("spec/fixtures/bbc_news/6072486.stm.html"),
      valid_hash: 'aaf7ed1219eb69c3126ea5d0774fbe7d'
    }
    @pa = BbcNewsPageParserV1.new(@valid_options)
  end

  it "should calculate a valid hash of the content" do
    @pa.hash.should eq @valid_options[:valid_hash]
  end

  it "should parse the title" do
    @pa.title.should eq "Son-in-law remanded over killing"
  end

  it "should parse the date in UTC" do
    @pa.date.should eq DateTime.parse("Sat Oct 21 14:41:10 +0000 2006")
    @pa.date.zone.should eq '+00:00'
  end

  it "should parse the content exactly like the old News Sniffer library" do
    @pa.content.first.should eq "<B>The son-in-law of a 73-year-old Castleford widow has been charged with her murder.</B>"
    @pa.content.last.should eq 'He denied the charges against him through his solicitor and is due to appear at Leeds Crown Court on Friday.'
    @pa.content.size.should eq 5
    @pa.hash.should eq @valid_options[:valid_hash]
  end

  it "should convert apostrophe and pound sign html entities in content" do
    @pa = BbcNewsPageParserV1.new page: 'S SF -->John&apos;s code sucks &amp; blows<!-- E BO'
    @pa.content.to_s.should match("John's")
    @pa.content.to_s.should match("sucks & blows")
  end

  it "should convert apostrophe and pound sign html entities in page titles" do
    @pa = BbcNewsPageParserV1.new page: '<meta name="Headline" content="John&apos;s code sucks &amp; blows!"/>'
    @pa.title.should match("John's")
    @pa.title.should match("sucks & blows")
  end
end
