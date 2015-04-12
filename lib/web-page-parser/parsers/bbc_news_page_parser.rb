# -*- coding: utf-8 -*-
module WebPageParser

    class BbcNewsPageParserFactory < WebPageParser::ParserFactory
      URL_RE = ORegexp.new("(www|news)\.bbc\.co\.uk/.+/([a-z-]+-)?[0-9-]+(\.stm)?$")
      INVALID_URL_RE = ORegexp.new("in_pictures|pop_ups|sport1")

      def self.can_parse?(options)
        url = options[:url].split('#').first
        if INVALID_URL_RE.match(url)
          nil
        else
          URL_RE.match(url)
        end
      end

      def self.create(options = {})
        BbcNewsPageParserV5.new(options)
      end
    end

    # BbcNewsPageParserV1 parses BBC News web pages exactly like the
    # old News Sniffer BbcNewsPage class did.  This should only ever
    # be used for backwards compatability with News Sniffer and is
    # never supplied for use by a factory.
    class BbcNewsPageParserV1 < WebPageParser::BaseRegexpParser

      TITLE_RE = ORegexp.new('<meta name="Headline" content="(.*)"', 'i')
      DATE_RE = ORegexp.new('<meta name="OriginalPublicationDate" content="(.*)"', 'i')
      CONTENT_RE = ORegexp.new('S (?:SF) -->(.*?)<!-- E BO', 'm')
      STRIP_TAGS_RE = ORegexp.new('</?(div|img|tr|td|!--|table)[^>]*>','i')
      WHITESPACE_RE = ORegexp.new('\t|')
      PARA_RE = Regexp.new(/<p>/i)
      
      def hash
        # Old News Sniffer only hashed the content, not the title
        Digest::MD5.hexdigest(content.join('').to_s)
      end

      private

      def date_processor
        begin
          # OPD is in GMT/UTC, which DateTime seems to use by default
          @date = DateTime.parse(@date)
        rescue ArgumentError
          @date = Time.now.utc
        end
      end

      def content_processor
        @content = STRIP_TAGS_RE.gsub(@content, '')
        @content = WHITESPACE_RE.gsub(@content, '')
        @content = decode_entities(@content)
        @content = @content.split(PARA_RE)
      end

    end

    # BbcNewsPageParserV2 parses BBC News web pages
    class BbcNewsPageParserV2 < WebPageParser::BaseRegexpParser

      TITLE_RE = ORegexp.new('<meta name="Headline" content="(.*)"', 'i')
      DATE_RE = ORegexp.new('<meta name="OriginalPublicationDate" content="(.*)"', 'i')
      CONTENT_RE = ORegexp.new('S BO -->(.*?)<!-- E BO', 'm')
      STRIP_BLOCKS_RE = ORegexp.new('<(table|noscript|script|object|form)[^>]*>.*?</\1>', 'i')
      STRIP_TAGS_RE = ORegexp.new('</?(b|div|img|tr|td|br|font|span)[^>]*>','i')
      STRIP_COMMENTS_RE = ORegexp.new('<!--.*?-->')
      STRIP_CAPTIONS_RE = ORegexp.new('<!-- caption .+?<!-- END - caption -->')
      WHITESPACE_RE = ORegexp.new('[\t ]+')
      PARA_RE = Regexp.new('</?p[^>]*>', Regexp::IGNORECASE)
      
      private
      
      def content_processor
        @content = STRIP_CAPTIONS_RE.gsub(@content, '')
        @content = STRIP_COMMENTS_RE.gsub(@content, '')
        @content = STRIP_BLOCKS_RE.gsub(@content, '')
        @content = STRIP_TAGS_RE.gsub(@content, '')
        @content = WHITESPACE_RE.gsub(@content, ' ')
        @content = @content.split(PARA_RE)
      end
      
      def date_processor
        begin
          # OPD is in GMT/UTC, which DateTime seems to use by default
          @date = DateTime.parse(@date)
        rescue ArgumentError
          @date = Time.now.utc
        end
      end

    end

    class BbcNewsPageParserV3 < BbcNewsPageParserV2
      CONTENT_RE = ORegexp.new('<div id="story\-body">(.*?)<div class="bookmark-list">', 'm')
      STRIP_FEATURES_RE = ORegexp.new('<div class="story-feature">(.*?)</div>', 'm')
      STRIP_MARKET_DATA_WIDGET_RE = ORegexp.new('<\!\-\- S MD_WIDGET.*? E MD_WIDGET \-\->')
      # BBC news is now in utf8

      def content_processor
        @content = STRIP_FEATURES_RE.gsub(@content, '')
        @content = STRIP_MARKET_DATA_WIDGET_RE.gsub(@content, '')
        super
      end
    end

    class BbcNewsPageParserV4 < BbcNewsPageParserV3
      CONTENT_RE = ORegexp.new('<div class=.story-body.>(.*?)<!-- / story\-body', 'm')
      STRIP_PAGE_BOOKMARKS = ORegexp.new('<div id="page-bookmark-links-head".+?</div>', 'm')
      STRIP_STORY_DATE = ORegexp.new('<span class="date".+?</span>', 'm')
      STRIP_STORY_LASTUPDATED = ORegexp.new('<span class="time\-text".+?</span>', 'm')
      STRIP_STORY_TIME = ORegexp.new('<span class="time".+?</span>', 'm')
      TITLE_RE = ORegexp.new('<h1 class="story\-header">(.+?)</h1>', 'm')
      STRIP_CAPTIONS_RE2 = ORegexp.new('<div class=.caption.+?</div>','m')
      STRIP_HIDDEN_A = ORegexp.new('<a class=.hidden.+?</a>','m')
      STRIP_STORY_FEATURE = ORegexp.new('<div class=.story\-feature.+?</div>', 'm')
      STRIP_HYPERPUFF_RE = ORegexp.new('<div class=.embedded-hyper.+?<div class=.hyperpuff.+?</div>.+?</div>', 'm')
      STRIP_MARKETDATA_RE = ORegexp.new('<div class=.market\-data.+?</div>', 'm')
      STRIP_EMBEDDEDHYPER_RE = ORegexp.new('<div class=.embedded\-hyper.+?</div>', 'm')
      STRIP_TWITTER_WIDGET_RE = ORegexp.new('<div[^>]+twitter\-module.*?</ul>','m')
      STRIP_TWITTER_WIDGET2_RE = ORegexp.new('<ul[^>]+tweets.+?</ul>.+?<ul[^>]+links.+?</ul>', 'm')
      def content_processor
        @content = STRIP_PAGE_BOOKMARKS.gsub(@content, '')
        @content = STRIP_STORY_DATE.gsub(@content, '')
        @content = STRIP_STORY_LASTUPDATED.gsub(@content, '')
        @content = STRIP_STORY_TIME.gsub(@content, '')
        @content = TITLE_RE.gsub(@content, '')
        @content = STRIP_CAPTIONS_RE2.gsub(@content, '')
        @content = STRIP_HIDDEN_A.gsub(@content, '')
        @content = STRIP_STORY_FEATURE.gsub(@content, '')
        @content = STRIP_HYPERPUFF_RE.gsub(@content, '')
        @content = STRIP_MARKETDATA_RE.gsub(@content, '')
        @content = STRIP_EMBEDDEDHYPER_RE.gsub(@content, '')
        @content = STRIP_TWITTER_WIDGET_RE.gsub(@content, '')
        @content = STRIP_TWITTER_WIDGET2_RE.gsub(@content, '')
        super
      end
    end


    class BbcNewsPageParserV5 < WebPageParser::BaseParser
      require 'nokogiri'

      def html_doc
        @html_document ||= Nokogiri::HTML(page)
      end

      def title
        return @title if @title
        @title = html_doc.css('h1.story-body__h1').text.strip

        # for older bbc articles
        if @title.empty?
          @title = html_doc.css('h1.story-header').text.strip
        end
        if @title.empty?
          @title = html_doc.css('div#meta-information h1').text.strip
        end

        # for very old bbc articles
        if @title.empty?
          if headline_meta = html_doc.at_css('meta[name=Headline]')
            @title = headline_meta['content'].to_s.strip
          end
        end

        @title
      end

      def content
        return @content if @content
        @content = []

        story_body = html_doc.css('div.story-body > div.story-body__inner')

        # Pre April 2015
        if story_body.children.empty?
          story_body = html_doc.css('div.story-body')
        end

        # for older bbc articles
        if story_body.children.empty?
          story_body = html_doc.css('div#story-body')
        end

        # for very old bbc articles
        if story_body.children.empty?
          story_body = html_doc.css('td.storybody')
        end

        story_body.children.each do |n|
          @content << n.text.strip if n.name == 'p'
          # Pre-April 2015 headings
          @content << n.text.strip if n.name == 'span' and n['class'].include? 'cross-head'
          # Post April 2015 headings
          @content << n.next.strip if n.name == 'h2' and n['class'].to_s =~ /crosshead/
        end
        @content
      end

      def date
        return @date if @date
        if date_meta = html_doc.at_css('meta[name=OriginalPublicationDate]')
          @date = DateTime.parse(date_meta['content']) rescue nil
        end
        @date
      end

    end

    class BbcNewsPageParserV6 < WebPageParser::BaseParser
      require 'nokogiri'

      def html_doc
        @html_document ||= Nokogiri::HTML(page)
      end

      def title
        @title ||= html_doc.css('h1.story-body__h1').text.strip
      end

      def content
        return @content if @content
        @content = []

        story_body = html_doc.css('div.story-body > div.story-body__inner')

        story_body.children.each do |n|
          case n.name
          when 'p', 'h2', 'h3'
            @content << n.text.strip
          when 'ul'
            if n['class'] =~ /story-body/
              n.css('li').each do |li|
                @content << li.text.strip
              end
            end
          end
        end
        @content
      end

      def date
        return @date if @date
        if date_meta = html_doc.at_css('meta[name=OriginalPublicationDate]')
          @date = DateTime.parse(date_meta['content']) rescue nil
        end
        @date
      end

    end

end
