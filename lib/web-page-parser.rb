# $:.unshift File.join(File.dirname(__FILE__), 'web-page-parser')

# Try using oniguruma on Ruby 1.8, if it's available
if RUBY_VERSION =~ /^1.8/
  begin
    require 'oniguruma'
  rescue LoadError
  end
end

# New Sniffer was originally developed against oniguruma, so when it's
# not available we just provide a compatible interface. This is a bit
# silly, especially for Ruby 1.9 (where it's built in!), but it saves
# changing lots of code.
unless defined?(Oniguruma)
  module Oniguruma
    class ORegexp < Regexp

      def self.new(r, options = "")
        ropts = 0
        ropts = ropts | Regexp::MULTILINE if options =~ /m/
        ropts = ropts | Regexp::IGNORECASE if options =~ /i/
        super(r, ropts)
      end

      def gsub(a, b)
        a.gsub(self, b)
      end
    end
  end
end

require 'web-page-parser/http.rb'  
require 'web-page-parser/base_parser.rb'
require 'web-page-parser/parser_factory.rb'
