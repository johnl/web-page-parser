
module WebPageParser
  require 'digest'
  require 'date'
  require 'htmlentities'

  class RetrieveError < StandardError ; end

  class BaseParser

    class << self
      attr_accessor :retrieve_session
    end

    attr_reader :url

    # takes a hash of options. The :url option passes the page url, and
    # the :page option passes the raw html page content for parsing
    def initialize(options = { })
      @url = options[:url]
      @page = options[:page]
      @guid = options[:guid]
    end

    # return the page contents, retrieving it from the server if necessary
    def page
      @page ||= retrieve_page
    end

    # request the page from the server and return the raw contents
    def retrieve_page(rurl = nil)
      durl = rurl || url
      return nil unless durl
      durl = filter_url(durl) if self.respond_to?(:filter_url)
      self.class.retrieve_session ||= WebPageParser::HTTP::Session.new
      self.class.retrieve_session.get(durl)
    end

    def title
      @title
    end

    def content
      @content || []
    end

    def date
    end

    def guid_from_url
    end

    def guid
      return @guid if @guid
      @guid = guid_from_url if url
      @guid
    end

    # Return a hash representing the textual content of this web page
    def hash
      digest = Digest::MD5.new
      digest << title.to_s
      digest << content.join('').to_s
      digest.to_s
    end

  end

  # BaseRegexpParser is designed to be sub-classed to write new
  # parsers that use regular. It provides some basic help but most of
  # the work needs to be done by the sub-class.
  #
  # Simple pages could be implemented by just defining new regular
  # expression constants, but more advanced parsing can be achieved
  # with the *_processor methods.
  #
  class BaseRegexpParser < BaseParser
    include Oniguruma


    # The regular expression to extract the title
    TITLE_RE = //

    # The regular expression to extract the date
    DATE_RE = //

    # The regular expression to extract the content
    CONTENT_RE = //

    # The regular expression to find all characters that should be
    # removed from any content.
    KILL_CHARS_RE = ORegexp.new('[\n\r]+')

    # The object used to turn HTML entities into real charaters
    HTML_ENTITIES_DECODER = HTMLEntities.new

    def initialize(options = { })
      super(options)
      @page = encode(@page)
    end

    # Handle any string encoding
    def encode(s)
      return s if s.nil?
      return s if s.valid_encoding?
      if s.force_encoding("iso-8859-1").valid_encoding?
        return s.encode('utf-8', 'iso-8859-1')
      end
      s
    end

    # return the page contents, retrieving it from the server if necessary
    def page
      @page ||= retrieve_page
    end

    # request the page from the server and return the raw contents
    def retrieve_page(rurl = nil)
      durl = rurl || url
      return nil unless durl
      durl = filter_url(durl) if self.respond_to?(:filter_url)
      self.class.retrieve_session ||= WebPageParser::HTTP::Session.new
      encode(self.class.retrieve_session.get(durl))
    end

    # The title method returns the title of the web page.
    #
    # It does the basic extraction using the TITLE_RE regular
    # expression and handles text encoding.  More advanced parsing can
    # be done by overriding the title_processor method.
    def title
      return @title if @title
      if matches = class_const(:TITLE_RE).match(page)
        @title = matches[1].to_s.strip
        title_processor
        @title = decode_entities(@title)
      end
    end

    # The date method returns a the timestamp of the web page, as a
    # DateTime object.
    #
    # It does the basic extraction using the DATE_RE regular
    # expression but the work of converting the text into a DateTime
    # object needs to be done by the date_processor method.
    def date
      return @date if @date
      if matches = class_const(:DATE_RE).match(page)
        @date = matches[1].to_s.strip
        date_processor
        @date
      end
    end

    # The content method returns the important body text of the web page.
    #
    # It does basic extraction and pre-processing of the page content
    # and then calls the content_processor method for any other more
    # custom processing work that needs doing.  Lastly, it does some
    # basic post processing and returns the content as a string.
    #
    # When writing a new parser, the CONTENT_RE constant should be
    # defined in the subclass.  The KILL_CHARS_RE constant can be
    # overridden if necessary.
    def content
      return @content if @content
      matches = class_const(:CONTENT_RE).match(page)
      if matches
        @content = class_const(:KILL_CHARS_RE).gsub(matches[1].to_s, '')
        content_processor
        @content.collect! { |p| decode_entities(p.strip) }
        @content.delete_if { |p| p == '' or p.nil? }
      end
      @content = [] if @content.nil?
      @content
    end

    # Convert html entities to unicode
    def decode_entities(s)
      HTML_ENTITIES_DECODER.decode(s)
    end

    private

    # get the constant from this objects class
    def class_const(sym)
      self.class.const_get(sym)
    end

    # Custom content parsing. It should split the @content up into an
    # array of paragraphs. Conversion to utf8 is done after this method.
    def content_processor
      @content = @content.split(/<p>/)
    end

    # Custom date parsing.  It should parse @date into a DateTime object
    def date_processor
    end

    # Custom title parsing.  It should clean up @title as
    # necessary. Conversion to utf8 is done after this method.
    def title_processor
    end

  end


end

