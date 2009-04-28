require 'cgi'
require 'uri'

# :main: Creole

# The Creole parses and translates Creole formatted text into
# XHTML. Creole is a lightwight markup syntax similar to what many
# WikiWikiWebs use. Example syntax:
#
#   = Heading 1 =
#   == Heading 2 ==
#   === Heading 3 ===
#   **Bold text**
#   //Italic text//
#   [[Links]]
#   |=Table|=Heading|
#   |Table |Cells   |
#   {{image.png}}
#
# The simplest interface is Creole.creolize. The default handling of
# links allow explicit local links using the [[link]] syntax. External
# links will only be allowed if specified using http(s) and ftp(s)
# schemes. If special link handling is needed, such as inter-wiki or
# hierachical local links, you must inherit Creole::CreoleParser and
# override make_local_link.
#
# You can customize the created anchor/image markup by overriding
# make_*_anchor/make_image.

module Creole

  VERSION = '0.3.2'

  # CreoleParseError is raised when the Creole parser encounters
  # something unexpected. This is generally now thrown unless there is
  # a bug in the parser.
  class CreoleParseError < Exception; end

  # Convert the argument in Creole format to HTML and return the
  # result. Example:
  #
  #    Creole.creolize("**Hello //World//**")
  #        #=> "<p><strong>Hello <em>World</em></strong></p>"
  #
  # This is an alias for calling CreoleParser#parse:
  #    CreoleParser.new.parse(creole)
  def self.creolize(creole)
    CreoleParser.new.parse(creole)
  end

  # Main Creole parser class.  Call CreoleParser#parse to parse Creole
  # formatted text.
  #
  # This class is not reentrant. A separate instance is needed for
  # each thread that needs to convert Creole to HTML.
  #
  # Inherit this to provide custom handling of links. The overrideable
  # methods are: make_local_link
  class CreoleParser

    # Create a new CreoleParser instance.
    def initialize
      @base = nil
      @allowed_schemes = [ 'http', 'https', 'ftp', 'ftps' ]
      @uri_scheme_re = @allowed_schemes.join('|')
    end

    # Parse and convert the argument in Creole text to HTML and return
    # the result. The resulting HTML does not contain <html> and
    # <body> tags.
    #
    # Example:
    #
    #    parser = CreoleParser.new
    #    parser.parse("**Hello //World//**")
    #       #=> "<p><strong>Hello <em>World</em></strong></p>"
    def parse(string)
      @out = ""
      @strong = false
      @p = false
      @stack = []
      parse_block(string)
      return @out
    end

    # Escape any characters with special meaning in HTML using HTML
    # entities.
    private
    def escape_html(string)
      CGI::escapeHTML(string)
    end

    # Escape any characters with special meaning in URLs using URL
    # encoding.
    private
    def escape_url(string)
      CGI::escape(string)
    end

    private
    def toggle_tag(tag, match)
      if @stack.include?(tag)
        if @stack.last == tag
          @stack.pop
          @out << '</' << tag << '>'
        else
          @out << escape_html(match)
        end
      else
        @stack.push(tag)
        @out << '<' << tag << '>'
      end
    end

    def end_paragraph
      while tag = @stack.pop
        @out << "</#{tag}>"
      end
      @p = false
    end

    def start_paragraph
      if not @p
        end_paragraph
        @out << '<p>'
        @stack.push('p')
        @p = true
      else
        @out << ' ' unless @out[-1,1] == ' '
      end
    end

    # Create anchor markup for direct links. This
    # method can be overridden to generate custom
    # markup, for example to add html additional attributes.
    private
    def make_direct_anchor(uri, text)
      '<a href="' << escape_html(uri) << '">' << escape_html(text) << '</a>'
    end

    # Create anchor markup for explicit links. This
    # method can be overridden to generate custom
    # markup, for example to add html additional attributes.
    private
    def make_explicit_anchor(uri, text)
      '<a href="' << escape_html(uri) << '">' << escape_html(text) << '</a>'
    end

    # Translate an explicit local link to a desired URL that is
    # properly URL-escaped. The default behaviour is to convert local
    # links directly, escaping any characters that have special
    # meaning in URLs. Relative URLs in local links are not handled.
    #
    # Examples:
    #
    #   make_local_link("LocalLink") #=> "LocalLink"
    #   make_local_link("/Foo/Bar") #=> "%2FFoo%2FBar"
    #
    # Must ensure that the result is properly URL-escaped. The caller
    # will handle HTML escaping as necessary. HTML links will not be
    # inserted if the function returns nil.
    #
    # Example custom behaviour:
    #
    #   make_local_link("LocalLink") #=> "/LocalLink"
    #   make_local_link("Wikipedia:Bread") #=> "http://en.wikipedia.org/wiki/Bread"
    private
    def make_local_link(link) #:doc:
      escape_url(link)
    end

    # Sanatize a direct url (e.g. http://wikipedia.org/). The default
    # behaviour returns the original link as-is.
    #
    # Must ensure that the result is properly URL-escaped. The caller
    # will handle HTML escaping as necessary. Links will not be
    # converted to HTML links if the function returns link.
    #
    # Custom versions of this function in inherited classes can
    # implement specific link handling behaviour, such as redirection
    # to intermediate pages (for example, for notifing the user that
    # he is leaving the site).
    private
    def make_direct_link(url) #:doc:
      return url
    end

    # Sanatize and prefix image URLs. When images are encountered in
    # Creole text, this function is called to obtain the actual URL of
    # the image. The default behaviour is to return the image link
    # as-is. No image tags are inserted if the function returns nil.
    #
    # Custom version of the method can be used to sanatize URLs
    # (e.g. remove query-parts), inhibit off-site images, or add a
    # base URL, for example:
    #
    #    def make_image_link(url)
    #       URI.join("http://mywiki.org/images/", url)
    #    end
    private
    def make_image_link(url) #:doc:
      return url
    end

    # Create image markup.  This
    # method can be overridden to generate custom
    # markup, for example to add html additional attributes or
    # to put divs around the imgs.
    private
    def make_image(uri, alt)
      if alt
        '<img src="' << escape_html(uri) << '" alt="' << escape_html(alt) << '"/>'
      else
        '<img src="' << escape_html(uri) << '"/>'
      end
    end

    private
    def make_explicit_link(link)
      begin
        uri = URI.parse(link)
        if uri.scheme and @allowed_schemes.include?(uri.scheme)
          return uri.to_s
        end
      rescue URI::InvalidURIError
      end
      return make_local_link(link)
    end

    def parse_inline(str)
      until str.empty?
        case str
        when /\A(\~)?((https?|ftps?):\/\/\S+?)(?=([,.?!:;"'\)])?(\s|$))/
          if $1
            @out << escape_html($2)
          else
            if uri = make_direct_link($2)
              @out << make_direct_anchor(uri, $2)
            else
              @out << escape_html($&)
            end
          end
        when /\A\[\[\s*([^|]*?)\s*(\|\s*(.*?))?\s*\]\]/m
          link = $1
          if uri = make_explicit_link(link)
            @out << make_explicit_anchor(uri, $3 || link)
          else
            @out << escape_html($&)
          end
        when /\A\{\{\{(.*)\}\}\}/
          @out << '<tt>' << escape_html($1) << '</tt>'
        when /\A\{\{\s*(.*?)\s*(\|\s*(.*?)\s*)?\}\}/
          if uri = make_image_link($1)
            @out << make_image(uri, $3)
          else
            @out << escape_html($&)
          end
        when /\A~([^\s])/
          @out << escape_html($1)
        when /\A\w+/
	  @out << $&
        when /\A\s+/
          @out << ' ' unless @out[-1,1] == ' '
	when /\A\*\*/
          toggle_tag 'strong', $&
        when /\A\/\//
          toggle_tag 'em', $&
        when /\A\\\\/
          @out << '<br/>'
        when /./
          @out << escape_html($&)
        else
          raise CreoleParseError, "Parse error at #{str[0,30].inspect}"
        end
        str = $'
      end
    end

    def parse_table_row(str)
      @out << '<tr>'
      str.scan(/\s*\|(=)?\s*((\[\[.*?\]\]|\{\{.*?\}\}|[^|~]|~.)*)(?=\||$)/) do
        unless $2.empty? and $'.empty?
          @out << ($1 ? '<th>' : '<td>')
          parse_inline($2) if $2
          until @stack.last == 'table'
            @out << '</' << @stack.pop << '>'
          end
          @out << ($1 ? '</th>' : '</td>')
        end
      end
      @out << '</tr>'
    end

    def make_nowikiblock(input)
      input.gsub(/^ (?=\}\}\})/, '')
    end

    def ulol(x); x=='ul'||x=='ol'; end

    def parse_block(str)
      until str.empty?
        case str
        when /\A\{\{\{\r?\n(.*?)\r?\n\}\}\}/m
          end_paragraph
          nowikiblock = make_nowikiblock($1)
          @out << '<pre>' << escape_html(nowikiblock) << '</pre>'
        when /\A\s*-{4,}\s*$/
          end_paragraph
          @out << '<hr/>'
        when /\A\s*(={1,6})\s*(.*?)\s*=*\s*$(\r?\n)?/
          end_paragraph
          level = $1.size
          @out << "<h#{level}>" << escape_html($2) << "</h#{level}>"
        when /\A[ \t]*\|.*$(\r?\n)?/
          unless @stack.include?('table')
            end_paragraph
            @stack.push('table')
            @out << '<table>'
          end
          parse_table_row($&)
        when /\A\s*$(\r?\n)?/
          end_paragraph
        when /\A(\s*([*#]+)\s*(.*?))$(\r?\n)?/
          line, bullet, item = $1, $2, $3
          tag = (bullet[0,1] == '*' ? 'ul' : 'ol')
          listre = /\A[ou]l\z/
          if bullet[0,1] == '#' or bullet.size != 2 or @stack.find { |x| x=='ol' || x == 'ul' }
            ulcount = @stack.inject(0) { |a,b| a + (ulol(b) ? 1 : 0) }
            while ulcount > bullet.size or not (@stack.empty? or ulol(@stack.last))
              @out << '</' + @stack.last << '>'
              ulcount -= 1 if ulol(@stack.pop)
            end

            if ulcount == bullet.size and @stack.last != tag
              @out << '</' << @stack.last << '>'
              @stack.pop
              ulcount -= 1
            end

            while ulcount < bullet.size
              @out << '<' << tag << '>'
              @stack.push tag
              ulcount += 1
            end
            @p = true
            @out << '<li>'
            @stack.push('li')
            parse_inline(item)
          else
            start_paragraph
            parse_inline(line)
          end
        when /\A([ \t]*\S+.*?)$(\r?\n)?/
          start_paragraph
          parse_inline($1)
        else
          raise CreoleParseError, "Parse error at #{str[0,30].inspect}"
        end
        #p [$&, $']
        str = $'
      end
      end_paragraph
      return @out
    end

  end # class CreoleParser

end # module Creole
