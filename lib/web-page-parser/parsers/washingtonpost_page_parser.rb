module WebPageParser
  class WashingtonPostPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new('www\.washingtonpost\.com/.*_story\.html')
    def self.can_parse?(options)
      url = options[:url].split('#').first
      URL_RE.match(url)
    end

    def self.create(options = {})
      WashingtonPostPageParserV3.new(options)
    end
  end

  # WashingtonPostPageParserV1 parses washpo web pages using html
  # parsing. Doesn't work since 2018
  class WashingtonPostPageParserV1 < WebPageParser::BaseParser
    require 'nokogiri'

    # WashPo articles have a guid in the url (as of Jan 2014, a
    # uuid)
    def guid_from_url
      # get the last large number from the url, if there is one
      url.to_s.scan(/[a-f0-9-]{30,40}/).last
    end

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('h1[property="dc.title"],div#article-topper > h1').text.strip
    end

    def content
      return @content if @content
      story_body = html_doc.css('div.article_body *,div#main-content article *,article[itemprop="articleBody"] *').select do |e|
        next false if e.attributes['class'].to_s["pin-and-stack"]
        e.name == 'p' or e.name == 'blockquote'
      end
      story_body.collect! do |p| 
        p.search('script,object').remove
        p = p.text.strip
      end
      @content = story_body.select { |p| !p.empty? }
    end

    def date
      return @date if @date
      # date in url is best source of first published date
      @date = DateTime.parse(url.scan(/[0-9]{4}\/[0-9]{2}\/[0-9]{2}/).first.to_s) rescue nil
      return @date if @date
      # failing that, get DC.date.issued which is actually last updated
      if date_meta = html_doc.at_css('meta[name="DC.date.issued"]')
        @date = DateTime.parse(date_meta['content']) rescue nil
      end
      @date
    end
  end

  # WashingtonPostPageParserV2 parses washpo web pages using html
  # parsing. Works since June 2018.
  class WashingtonPostPageParserV2 < WebPageParser::BaseParser
    require 'nokogiri'

    # WashPo articles have a uuid in the url
    def guid_from_url
      # get the last large number from the url, if there is one
      url.to_s.scan(/[a-f0-9-]{30,40}/).last
    end

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('h1[itemprop="headline"], header h1#main-content').text.strip
    end

    def content
      return @content if @content
      story_body = html_doc.css('article:first p,article:first div.subhead').collect { |p| p.text.strip }
      @content = story_body.select { |p| !p.empty? }
    end

    def date
      return @date if @date
      if date_meta = html_doc.at_css('*[itemprop="datePublished"]')
        @date = DateTime.parse(date_meta['content']).new_offset(0) rescue nil
      end
      @date
    end

  end

  # WashingtonPostPageParserV3 parses washpo web pages using html
  # parsing. Works since October 2019.
  class WashingtonPostPageParserV3 < WebPageParser::BaseParser
    require 'nokogiri'

    # WashPo articles have a uuid in the url
    def guid_from_url
      # get the last large number from the url, if there is one
      url.to_s.scan(/[a-f0-9-]{30,40}/).last
    end

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('header h1[data-qa="headline"]').text.strip
    end

    def content
      return @content if @content
      story_body = html_doc.css('article:first div.article-body p').collect { |p| p.text.strip }
      @content = story_body.select { |p| !p.empty? }
    end

    def date
      return @date if @date
      if date_meta = html_doc.at_css('meta[property="article:published_time"]')
        @date = DateTime.parse(date_meta['content']) rescue nil
      end
      @date ||= DateTime.parse(html_doc.css('div.display-date').text).new_offset(0) rescue nil
      @date
    end

  end

end
