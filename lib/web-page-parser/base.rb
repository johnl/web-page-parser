
module WebPageParser
  require 'digest'

  class BaseParser
    attr_reader :title, :date, :content
    attr_reader :url, :guid, :page

    def initialize(options = { })
      @url = options[:url]
      @page = options[:page]
    end

    def parse!
      nil
    end

    # Return a hash representing the content of this web page
    def hash
      digest = Digest::MD5.new
      digest << title.to_s
      digest << date.to_i.to_s
      digest << content.to_s
      digest.to_s
    end

  end


end

