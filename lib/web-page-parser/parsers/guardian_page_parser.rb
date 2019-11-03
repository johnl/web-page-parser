module WebPageParser
  class GuardianPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("(www\.)?(the)?guardian\.(co\.uk|com)/[a-z-]+(/[a-z-]+)?/[0-9]{4}/[a-z]{3}/[0-9]{1,2}/[a-z-]{5,200}$")
    INVALID_URL_RE = ORegexp.new("/cartoon/|/commentisfree/poll/|/video/[0-9]+|/gallery/[0-9]+|/poll/[0-9]+")
    def self.can_parse?(options)
      url = options[:url].split('#').first
      return nil if INVALID_URL_RE.match(url)
      URL_RE.match(url)
    end

    def self.create(options = {})
      GuardianPageParserV4.new(options)
    end
  end

  # GuardianPageParserV1 parses Guardian web pages using regexps
  class GuardianPageParserV1 < WebPageParser::BaseRegexpParser
    TITLE_RE = ORegexp.new('<meta property="og:title" content="(.*)"', 'i')
    DATE_RE = ORegexp.new('<meta property="article:published_time" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('article-body-blocks">(.*?)<div id="related"', 'm')
    STRIP_TAGS_RE = ORegexp.new('</?(a|span|div|img|tr|td|!--|table)[^>]*>','i')
    STRIP_SCRIPTS_RE = ORegexp.new('<script[^>]*>.*?</script>','i')
    PARA_RE = Regexp.new(/<(p|h2)[^>]*>(.*?)<\/\1>/i)

    private

    def date_processor
      begin
        # OPD is in GMT/UTC, which DateTime seems to use by default
        @date = DateTime.parse(@date)
      rescue ArgumentError
        @date = Time.now.utc
      end
    end

    def content_processor
      @content = STRIP_TAGS_RE.gsub(@content, '')
      @content = STRIP_SCRIPTS_RE.gsub(@content, '')
      @content = @content.scan(PARA_RE).collect { |a| a[1] }
    end

    def filter_url(url)
      url.to_s.gsub("www.guprod.gnl", "www.guardian.co.uk") # some wierd guardian problem with some older articles
    end

  end

  # GuardianPageParserV2 parses Guardian web pages using html
  # parsing. It can parse articles old and new but sometimes has
  # slightly different results due to it stripping most html tags
  # (like <strong>) which the V1 parser didn't do.
  class GuardianPageParserV2 < WebPageParser::BaseParser
    require 'nokogiri'

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def css_first_text(top_e, *selectors)
      selectors.each do |s|
        top_e.css(s).each do |e|
          next if e.nil?
          text = e.text.strip
          return text unless text.empty?
        end
      end
      nil
    end

    def title
      return @title if @title
      @title = css_first_text(html_doc, 'h1[itemprop=headline]', 'div#main-article-info h1:first')
      @title = html_doc.css('title').text.split('|').first.strip if @title.nil?
      @title
    end

    def content
      return @content if @content
      story_body = html_doc.css('div#article-body-blocks *, div[itemprop=articleBody] *').select do |e|
        e.name == 'p' or e.name == 'h2' or e.name == 'h3'
      end
      story_body.collect { |p| p.text.empty? ? nil : p.text.strip }.compact
    end

    def date
      return @date if @date
      if date_meta = html_doc.at_css('meta[property="article:published_time"]')
        @date = DateTime.parse(date_meta['content']) rescue nil
      end
      @date
    end

    def filter_url(url)
      # some wierd guardian problem with some older articles
      url.to_s.gsub("www.guprod.gnl", "www.guardian.co.uk") 
    end
  end

  class GuardianPageParserV3 < GuardianPageParserV2
    def content
      return @content if @content
      story_body = html_doc.css('div#article-body-blocks *, div[itemprop=articleBody] *').select do |e|
        e.name == 'p' or e.name == 'h2' or e.name == 'h3' or e.name == 'ul'
      end
      story_body.collect do |p|
        if p.name == 'ul'
          p.css('li').collect { |li| li.text.empty? ? nil : li.text.strip }
        else
          p.text.empty? ? nil : p.text.strip
        end
      end.flatten.compact
    end
  end

  class GuardianPageParserV4 < GuardianPageParserV3
    def content
      return @content if @content

      story_body = html_doc.css('article div[itemprop=articleBody] > *').select do |e|
        e.name == 'p' || e.name == 'h2' || e.name == 'h3' || e.name == 'ul'
      end
      story_body = story_body.collect do |p|
        if p.name == 'ul'
          next if p.classes.include?('social')

          p.css('li').collect { |li| li.text.empty? ? nil : li.text.strip }
        else
          p.text.empty? ? nil : p.text.strip
        end
      end.flatten.compact
      if (description_meta = html_doc.at_css('meta[itemprop="description"]'))
        story_body.unshift description_meta['content']
      end
      story_body
    end

    def date
      return @date if @date

      if (date_meta = html_doc.at_css('time[itemprop="datePublished"]'))
        @date = parse_datetime_or_nil date_meta['datetime']
      end
      @date
    end

    def guid
      guid = super
      guid.nil? ? nil : guid.gsub('http:', 'https:')
    end

    def url
      super.gsub('http:', 'https:')
    end
  end
end
