$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'web-page-parser'

share_as :AllPageParsers do
  it "is initialized with a hash containing :url and :page keys" do
    wpp = WebPageParser::BaseParser.new(@valid_options)
    wpp.url.should == @valid_options[:url]
    wpp.page.should == @valid_options[:page]
  end

  context "when hashing the content" do
    before :each do
      @wpp = WebPageParser::BaseParser.new(@valid_options)
      @hash = @wpp.hash
    end

    it "calculates a hash using the title" do
      @wpp.instance_eval("@title='different'")
      @wpp.hash.should_not == @hash
    end

    it "calculates a hash using the date" do
      @wpp.instance_eval("@date=Time.now")
      @wpp.hash.should_not == @hash
    end

    it "calculates a hash using the content" do
      @wpp.instance_eval("@content='different'")
      @wpp.hash.should_not == @hash
    end
  end
end

describe WebPageParser::BaseParser do
  it_should_behave_like AllPageParsers

  before :each do
    @valid_options = { 
      :url => 'http://news.bbc.co.uk', 
      :page => '<html></html>',
      :valid_hash => 'cfcd208495d565ef66e7dff9f98764da'
    }
  end

end
