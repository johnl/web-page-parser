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
