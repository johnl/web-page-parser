
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

  class BaseFactory

    def type
      ""
    end
    
    def create
      nil
    end

    @@factories = []

    def self.add_factory(f)
      @@factories << f
    end

    def self.factories
      @@factories
    end

    # Load all the plugins in the given directory
    def self.load(dirname)
      Dir.open(dirname) do |fn|
        next unless fn =~ /\.rb$/
        require "#{dirname}/#{fn}"
      end
    end
  end

  BaseFactory.load(File.join(File.dirname(__FILE__), 'parsers'))

end
