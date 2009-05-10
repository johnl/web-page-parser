# -*- coding: utf-8 -*-
module WebPageParser

    class BbcNewsPageParserFactory < WebPageParser::ParserFactory
      URL_RE = ORegexp.new("news\.bbc\.co\.uk/.*/[0-9]+\.stm")
      INVALID_URL_RE = ORegexp.new("in_pictures")

      def self.can_parse?(options)
        if INVALID_URL_RE.match(options[:url])
          nil
        else
          URL_RE.match(options[:url])
        end
      end

      def self.create(options = {})
        BbcNewsPageParserV2.new(options)
      end
    end

    # BbcNewsPageParserV1 parses BBC News web pages exactly like the
    # old News Sniffer BbcNewsPage class did.  This should only ever
    # be used for backwards compatability with News Sniffer and is
    # never supplied for use by a factory.
    class BbcNewsPageParserV1 < WebPageParser::BaseParser

      TITLE_RE = ORegexp.new('<meta name="Headline" content="(.*)"', 'i')
      DATE_RE = ORegexp.new('<meta name="OriginalPublicationDate" content="(.*)"', 'i')
      CONTENT_RE = ORegexp.new('S (?:SF|BO) -->(.*?)<!-- E BO', 'm')
      STRIP_TAGS_RE = ORegexp.new('</?(div|img|tr|td|!--|table)[^>]*>','i')
      WHITESPACE_RE = ORegexp.new('\t|')
      PARA_RE = Regexp.new(/<p>/i)
      
      # Old News Sniffer didn't do any encoding conversion
      ICONV = nil

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
      STRIP_BLOCKS_RE = ORegexp.new('<(table|noscript|script|object|form)[^>]*>.*</\1>', 'i')
      STRIP_TAGS_RE = ORegexp.new('</?(b|div|img|tr|td|br|font|span)[^>]*>','i')
      STRIP_COMMENTS_RE = ORegexp.new('<!--.*?-->')
      STRIP_CAPTIONS_RE = ORegexp.new('<!-- caption .+<!-- END - caption -->')
      WHITESPACE_RE = ORegexp.new('[\t ]+')
      PARA_RE = Regexp.new('</?p[^>]*>')
      
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
end
