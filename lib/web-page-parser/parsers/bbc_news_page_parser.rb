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

      def parse!
        @title = $1 if @page =~ /<meta name="Headline" content="(.*)"/i
        if @page =~ /<meta name="OriginalPublicationDate" content="(.*)"/i
          begin
            # OPD is in GMT/UTC, which DateTime seems to use by default
            @date = DateTime.parse($1)
          rescue ArgumentError
            @date = Time.now.utc
          end
        end
        if @page =~ /S SF -->(.*?)<!-- E BO/m or page_data =~ /S BO -->(.*?)<!-- E BO/m
          @content = $1
          @content.gsub!(/\n|\r|\t/, '')
          @content.gsub!(/<\/?(div|img|tr|td|!--|table)[^>]*>/i, '')
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
