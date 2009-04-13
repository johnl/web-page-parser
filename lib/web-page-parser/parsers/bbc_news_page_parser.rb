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

end
