
module WebPageParser
  require 'digest'
  require 'date'
  require 'oniguruma'

  class BaseParser
    include Oniguruma
    attr_reader :title, :date, :content
    attr_reader :url, :guid, :page

    TITLE_RE = //
    DATE_RE = //
    CONTENT_RE = //
    KILL_CHARS_RE = ORegexp.new('[\n\r]+')

    def initialize(options = { })
      @url = options[:url]
      @page = options[:page]
    end

    def title
      return @title if @title
      if matches = self.class.const_get(:TITLE_RE).match(page)
        @title = matches[1].to_s.strip
      end
    end

    def date
      return @date if @date
      if matches = self.class.const_get(:DATE_RE).match(page)
        @date = matches[1].to_s.strip
      end
    end

    def content
      return @content if @content
      matches = self.class.const_get(:CONTENT_RE).match(page)
      if matches
        @content = self.class.const_get(:KILL_CHARS_RE).gsub(matches[1].to_s, '')
      end
      @content
    end

    # Return a hash representing the content of this web page
    def hash
      digest = Digest::MD5.new
      digest << title.to_s
      digest << (date.respond_to?(:to_i) ? date.to_i.to_s : date.to_s)
      digest << content.to_s
      digest.to_s
    end

  end


end

