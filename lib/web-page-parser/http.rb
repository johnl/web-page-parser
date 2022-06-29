module WebPageParser
  module HTTP
    require 'curb'
    require 'zlib'

    class Response < String
      attr_accessor :curl

      def initialize(s, curl)
        self.curl = curl
        super(s)
      end
    end

    class Session

      class CurlError < StandardError ; end

      def curl
        @curl ||= Curl::Easy.new do |c|
          c.timeout = 8
          c.connect_timeout = 8
          c.dns_cache_timeout = 600
          c.enable_cookies = true
          c.follow_location = true
          c.max_redirects = 6
          c.autoreferer = true
          c.headers["User-Agent"] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0'
          c.headers["Accept-encoding"] = 'gzip, deflate'
          c.headers["Accept-Language"] = 'en-GB,en;q=0.5'
        end
      end

      def get(url)
        curl.url = url
        if curl.perform == false
          raise CurlError, "curl.perform returned false"
        end
        uncompressed = gunzip(curl.body_str)
        uncompressed = inflate(curl.body_str) if uncompressed.nil?
        final_body = uncompressed || curl.body_str
        if final_body.respond_to?(:force_encoding)
          # Not sure if this is right. works for BBC/Guardian/New York Times anyway
          final_body.force_encoding("utf-8")
        end
        Response.new(final_body, curl)
      end

      def inflate(s)
        Zlib::Inflate.inflate(s)
      rescue Zlib::DataError
        nil
      end

      def gunzip(s)
        s = StringIO.new(s)
        Zlib::GzipReader.new(s).read
      rescue Zlib::DataError
      rescue Zlib::GzipFile::Error
        nil
      end
    end
  end

end
