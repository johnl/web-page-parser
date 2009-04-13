module WebPageParser
  class ParserFactory

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

    def self.inherited(factory)
      self.add_factory(factory)
    end

  end

  ParserFactory.load(File.join(File.dirname(__FILE__), 'parsers'))

end
