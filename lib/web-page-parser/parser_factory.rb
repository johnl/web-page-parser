module WebPageParser
  class ParserFactory

    def can_parse?(url, page = nil)
      false
    end

    def create(url, page = nil)
      nil
    end

    @@factories = []

    def self.add_factory(f)
      @@factories << f unless @@factories.include? f
    end

    def self.factories
      @@factories
    end

    # Return a PageParser than can parse the given page
    def self.parser_for(url, page = nil)
      @@factories.each do |factory|
        return factory.create(url, page) if factory.can_parse?(url, page)
      end
      nil
    end

    # Load all the plugins in the given directory
    def self.load(dirname)
      Dir.open(dirname).each do |fn|
        next unless fn =~ /page_parser\.rb$/
        require File.join(dirname, fn)
      end
    end

    def self.inherited(factory)
      self.add_factory(factory)
    end

  end

  ParserFactory.load(File.join(File.dirname(__FILE__), 'parsers'))

end
