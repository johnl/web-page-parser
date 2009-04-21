$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'web-page-parser'
include WebPageParser

describe BbcNewsPageParserFactory do
  before do
    @valid_urls = [
                   "http://news.bbc.co.uk/1/hi/entertainment/6984082.stm",
                   "http://news.bbc.co.uk/1/hi/northern_ireland/7996478.stm",
                   "http://news.bbc.co.uk/1/hi/uk/7995652.stm",
                   "http://news.bbc.co.uk/1/hi/england/derbyshire/7996494.stm",
                   "http://news.bbc.co.uk/2/low/uk_news/england/devon/7996447.stm"
                  ]
    @invalid_urls = [
                     "http://news.bbc.co.uk/2/hi/health/default.stm",
                     "http://news.bbc.co.uk/2/low/europe/default.stm",
                     "http://news.bbc.co.uk/2/hi/in_pictures/default.stm",
                     "http://news.bbc.co.uk/sport"
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
end

describe BbcNewsPageParserV2 do
  before do
    @valid_options = { 
      :url => 'http://news.bbc.co.uk/1/hi/world/middle_east/8011268.stm',
      :page => File.read("spec/fixtures/bbc_news/8011268.stm.html"),
      :valid_hash => ''
    }
    @pa = BbcNewsPageParserV2.new(@valid_options)
    @pa.parse!
  end

  it "should parse the title" do
    @pa.title.should == "Obama invites Middle East heads"
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
    @pa.parse!
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
end
