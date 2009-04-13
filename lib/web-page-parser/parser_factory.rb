module WebPageParser
  class ParserFactory

    # return true if the Parser can handle the given page. options
    # hash must have a :url key
    def can_parse?(options = {})
      false
    end

    # Allocate a new parser. options hash is passed to new method of
    # parser class.
    def create(options = {})
      nil
    end

    @@factories = []

    def self.add_factory(f)
      @@factories << f unless @@factories.include? f
    end

    def self.factories
      @@factories
    end

    # Return a PageParser than can parse the given page. options hash
    # must have a :url key
    def self.parser_for(options = {})
      @@factories.each do |factory|
        return factory.create(options) if factory.can_parse?(options)
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

    # Keep track of any newly defined factories
    def self.inherited(factory)
      self.add_factory(factory)
    end

  end

  ParserFactory.load(File.join(File.dirname(__FILE__), 'parsers'))

end
