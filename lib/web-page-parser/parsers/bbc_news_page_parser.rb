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

      def self.find_title_in(page)
        @title_regexp ||= ORegexp.new('<meta name="Headline" content="(.*)"', 'i')
        if matches = @title_regexp.match(page)
          matches[1] 
        end
      end

      def self.find_date_in(page)
        @date_regexp ||= ORegexp.new('<meta name="OriginalPublicationDate" content="(.*)"', 'i')
        if matches = @date_regexp.match(page)
          matches[1]
        end
      end

      def self.find_content_in(page)
        @content_regexp_1 ||= ORegexp.new('S SF -->(.*?)<!-- E BO', 'm')
        @content_regexp_2 ||= ORegexp.new('S BO -->(.*?)<!-- E BO', 'm')
        matches = @content_regexp_1.match(page)
        matches = @content_regexp_2.match(page) unless matches
        if matches
          matches[1]
        end
      end

      def self.strip_tags_from!(content)
        @strip_tags_regexp ||= ORegexp.new('</?(div|img|tr|td|!--|table)[^>]*>','i')
        @strip_tags_regexp.gsub!(content, '')
      end

      def self.normalize_whitespace_in!(content)
        @whitespace_regexp ||= ORegexp.new('\n|\r|\t|')
        @whitespace_regexp.gsub!(content, '')
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
          @content = @content.split(/<p>/i)
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
