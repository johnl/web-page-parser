# $:.unshift File.join(File.dirname(__FILE__), 'web-page-parser')
if RUBY_VERSION =~ /^1.8/
  require 'oniguruma'
else
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
end
  
require 'web-page-parser/base_parser.rb'
require 'web-page-parser/parser_factory.rb'
