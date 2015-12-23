module WebPageParser
  class TheInterceptPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new('firstlook.org/theintercept/[0-9]{4}/[0-9]{2}/[0-9]{2}/[a-z0-9-]+')
    def self.can_parse?(options)
      URL_RE.match(options[:url])
    end

    def self.create(options = {})
      TheInterceptPageParserV1.new(options)
    end
  end

  # TheInterceptPageParserV1 parses "The Intercept" web pages using html
  # parsing.
  class TheInterceptPageParserV1 < WebPageParser::BaseParser
    require 'nokogiri'

    # WashPo articles have a guid in the url (as of Jan 2014, a
    # uuid)
    def guid_from_url
      # get the last large number from the url, if there is one
      url.to_s.scan(/https:\/\/firstlook.org\/theintercept\/[0-9]{4}\/[0-9]{2}\/[0-9]{2}\/[a-z0-9-]+/).last
    end

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      return @title if @title
      title_meta = html_doc.at_css('meta[property="og:title"]')
      title = nil
      if title_meta
        title = title_meta['content'].to_s.strip
      end
      if title.nil?
        title = html_doc.css('head title').text.strip
      end
      title = title.gsub(/- The Intercept$/,'')
      @title = title.strip
    end

    def content
      return @content if @content
      story_body = html_doc.css('div.PostContent div p, article div.ti-body p').collect do |p|
        p.text.strip.gsub(160.chr(Encoding::UTF_8), ' ') # convert &nbsp; to actual space
      end
      @content = story_body.select { |p| !p.empty? }
    end

    def date
      return @date if @date
      if date_meta = html_doc.at_css('meta[property="article:published_time"]')
        date_string = date_meta['content'].scan(/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\+[0-9]{2}:[0-9]{2}/).first
        @date = DateTime.parse(date_string) rescue nil
      end
      return @date if @date
      if date_span = html_doc.css('span.PostByline-date')
        date_string = date_span.text.strip
        @date = DateTime.parse(date_string) rescue nil
      end
      return @date if @date
      # failing that, get it from the url
      @date = DateTime.parse(url.scan(/[0-9]{4}\/[0-9]{2}\/[0-9]{2}/).first.to_s) rescue nil
    end
  end
end
