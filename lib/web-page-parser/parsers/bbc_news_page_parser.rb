# -*- coding: utf-8 -*-
module WebPageParser

    class BbcNewsPageParserFactory < WebPageParser::ParserFactory
      @url_regexp = Regexp.new("news\.bbc\.co\.uk/.*/[0-9]+\.stm")

      def self.can_parse?(options)
        @url_regexp.match(options[:url])
      end

      def self.create(options = {})
        BbcNewsPageParser.new
      end
    end

    class BbcNewsPageParser < WebPageParser::BaseParser

    end

    # BbcNewsPageParserV1 parses BBC News web pages exactly like the
    # old News Sniffer BbcNewsPage class did.  This should only ever
    # be used for backwards compatability with News Sniffer and is
    # never supplied for use by a factory.
    class BbcNewsPageParserV1 < WebPageParser::BaseParser
      require 'cgi'

      TITLE_RE = ORegexp.new('<meta name="Headline" content="(.*)"', 'i')
      DATE_RE = ORegexp.new('<meta name="OriginalPublicationDate" content="(.*)"', 'i')
      CONTENT_RE = ORegexp.new('S (SF|BO) -->(.*?)<!-- E BO', 'm')
      STRIP_TAGS_RE = ORegexp.new('</?(div|img|tr|td|!--|table)[^>]*>','i')
      WHITESPACE_RE = ORegexp.new('\n|\r|\t|')
      PARA_RE = Regexp.new(/<p>/i)

      def self.find_title_in(page)
        if matches = TITLE_RE.match(page)
          matches[1] 
        end
      end

      def self.find_date_in(page)
        if matches = DATE_RE.match(page)
          matches[1]
        end
      end

      def self.find_content_in(page)
        matches = CONTENT_RE.match(page)
        if matches
          matches[2]
        end
      end

      def self.strip_tags_from!(content)
        STRIP_TAGS_RE.gsub!(content, '')
      end

      def self.normalize_whitespace_in!(content)
        WHITESPACE_RE.gsub!(content, '')
      end

      def parse!
        @title = BbcNewsPageParserV1.find_title_in(@page)
        if date = BbcNewsPageParserV1.find_date_in(@page)
          begin
            # OPD is in GMT/UTC, which DateTime seems to use by default
            @date = DateTime.parse(date)
          rescue ArgumentError
            @date = Time.now.utc
          end
        end
        if @content = BbcNewsPageParserV1.find_content_in(@page)
          BbcNewsPageParserV1.normalize_whitespace_in!(@content)
          BbcNewsPageParserV1.strip_tags_from!(@content)
          @content = @content.split(PARA_RE)
        end
      end

      def hash
        Digest::MD5.hexdigest(@content.join) if @content.respond_to?(:join)
      end

      private

      def unhtml(s)
        t = CGI::unescapeHTML(s.to_s)
        t = t.gsub(/&apos;/i, "'")
        t = t.gsub(/&pound;/i, "£")
        t
      end

    end
end
