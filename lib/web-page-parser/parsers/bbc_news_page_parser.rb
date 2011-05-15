# -*- coding: utf-8 -*-
module WebPageParser

    class BbcNewsPageParserFactory < WebPageParser::ParserFactory
      URL_RE = ORegexp.new("(www|news)\.bbc\.co\.uk/.+/([a-z-]+-)?[0-9]+(\.stm)?$")
      INVALID_URL_RE = ORegexp.new("in_pictures|pop_ups|sport1")

      def self.can_parse?(options)
        if INVALID_URL_RE.match(options[:url])
          nil
        else
          URL_RE.match(options[:url])
        end
      end

      def self.create(options = {})
        BbcNewsPageParserV4.new(options)
      end
    end

    # BbcNewsPageParserV1 parses BBC News web pages exactly like the
    # old News Sniffer BbcNewsPage class did.  This should only ever
    # be used for backwards compatability with News Sniffer and is
    # never supplied for use by a factory.
    class BbcNewsPageParserV1 < WebPageParser::BaseParser

      TITLE_RE = ORegexp.new('<meta name="Headline" content="(.*)"', 'i')
      DATE_RE = ORegexp.new('<meta name="OriginalPublicationDate" content="(.*)"', 'i')
      CONTENT_RE = ORegexp.new('S (?:SF) -->(.*?)<!-- E BO', 'm')
      STRIP_TAGS_RE = ORegexp.new('</?(div|img|tr|td|!--|table)[^>]*>','i')
      WHITESPACE_RE = ORegexp.new('\t|')
      PARA_RE = Regexp.new(/<p>/i)
      
      def hash
        # Old News Sniffer only hashed the content, not the title
        Digest::MD5.hexdigest(content.to_s)
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
    class BbcNewsPageParserV2 < WebPageParser::BaseParser

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
      ICONV = nil # BBC news is now in utf8
      
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
        super
      end
    end
    
end
