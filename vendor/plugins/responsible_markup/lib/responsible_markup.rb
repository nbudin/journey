# :title: Responsible Markup extension for Test::Unit
# =Responsible Markup extension for Test::Unit
#
# See README for a full explanation of this library, or see ResponsibleMarkup
# for a listing and explanation of the available methods.

require 'net/http'
require 'uri'
require 'rexml/document'
require 'digest/md5'
require 'tmpdir'
require 'cgi'
require 'strscan'

# ResponsibleMarkup is a module which provides various assertions for use in
# your unit tests for:
#
# * (X)HTML markup validity...
# * Unobtrusive Javascript...
# * Backwards-compatible XHTML...
# * ...and other hallmarks of responsible web development
#
# Please refer to the README for an overview.
module ResponsibleMarkup
  # see +assert_valid_html+
  MSG_INVALID_XHTML            = 'Output is invalid (X)HTML.'
  # see +assert_compatible_empty_elements+
  MSG_EMPTY_ELEMENTS           = 'Output has empty elements which may be incompatible with older browsers.'
  # see +assert_no_empty_attributes+
  MSG_EMPTY_ATTRIBUTES         = 'Output has empty attributes.'
  # see +assert_no_long_style_attributes+
  MSG_LONG_STYLE_ATTRIBUTES    = "Output has overly long style attributes.\nConsider refactoring this display information into a CSS class."
  # see +assert_doctype+
  MSG_DOCTYPE_ERROR            = 'Output doctype does not match expected value(s).'
  # see +assert_has_xml_prolog+
  MSG_NO_XML_PROLOG            = 'Output has no XML prolog.'
  # see +assert_content_type+
  MSG_CONTENT_TYPE_ERROR       = 'Output content type did not match the expected content type.'
  # see +assert_content_type
  MSG_CONTENT_TYPE_MISMATCH    = 'Expected content type was <?> but http-equiv content type was <?>.'
  # see +assert_content_type
  MSG_CONTENT_TYPE_HTTP_MISMATCH = 'Expected content type was <?> but HTTP content type was <?>.'
  # see +assert_content_type
  MSG_CONTENT_TYPE_NONE        = 'Expected content type was <?> but no content type was found.'
  # see +assert_unobtrusive_javascript+
  MSG_OBTRUSIVE_JAVASCRIPT     = 'Output has Javascript mixed into the markup.'
  # see +assert_valid_xml+
  MSG_INVALID_XML              = 'Output is invalid XML.'
  
  # Default W3C Validator.
  W3C_VALIDATOR = 'http://validator.w3.org/check'
  # Stem of the filename validation results are saved to when cached.
  CACHE_FILENAME_STEM = 'responsible_markup.'
  # Twenty characters is enough to deserve its own CSS class.
  MAX_STYLE_ATTRIBUTE_LENGTH = 20
  # Required attributes for XHTML 1.0.
  REQUIRED_ELEMENT_ATTRIBUTES = ["action", "alt", "cols", "content", "dir",
                                 "for", "href", "id", "label", "rows", "src",
                                 "summary", "title", "type", "xml:lang"]
  # Possible inline Javascript events.
  JAVASCRIPT_EVENTS = ["blur", "focus", "contextmenu", "load", "resize",
                       "scroll", "unload", "click", "dblclick", "mousedown",
                       "mouseup", "mouseenter", "mouseleave", "mousemove",
                       "mouseover", "mouseout", "change", "reset", "select",
                       "submit", "keydown", "keypress", "keyup", "abort",
                       "error"]
  # Taken from an ALA article on doctypes.
  DEFAULT_DOCTYPES = {
    :xhtml_10_strict => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    :xhtml_10_transitional => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    :xhtml_10_frameset => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
    :xhtml_11 => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    :html_401_strict => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
    :html_401_transitional => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
    :html_401_frameset => '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
  }
  
  # These don't capture the entirety of the element if there is a < or > inside
  # the Javascript they're attempting to find. They still match, though, and I
  # find myself unwilling to refactor the entire structure just to make the
  # error messages more perfect. "'Splodies here" should be enough.
  if RUBY_VERSION == '1.8.2'
    OBTRUSIVE_JAVASCRIPTS = {
      :blank_hrefs => /<[^<>]+href="#"[^<>]*>/im,
      :javascript_hrefs => /<[^<>]+href="javascript:[^<>]*>/im,
      :inline_events => Regexp.new("<[^<>]+(?:#{JAVASCRIPT_EVENTS.map{|e|'on'+e}.join('|')})[^<>]*>", Regexp::MULTILINE | Regexp::IGNORECASE),
      :script_elements_in_body => /<script.+<\/script>/im
    }
  else
    OBTRUSIVE_JAVASCRIPTS = {
      :blank_hrefs => /<.+href="#"[^<>]*>/im,
      :javascript_hrefs => /<[^<>]+href="javascript:[^<>]*>/im,
      :inline_events => Regexp.new("<[^<>]+(?:#{JAVASCRIPT_EVENTS.map{|e|'on'+e}.join('|')})[^<>]*>", Regexp::MULTILINE | Regexp::IGNORECASE),
      :script_elements_in_body => /<script.+<\/script>/im
    }
  end

  # An error raised when ResponsibleMarkup::assert_valid_html cannot connect to
  # the specified W3C Validator.
  class ConnectionError < Exception; end
  
  # An error raises when ResponsibleMarkup::assert_valid_html cannot parse the
  # XML returned by the W3C Validator.
  #
  # <b>N.B.: This error may be raised if the cached results (in the system's
  # temp directory) have become corrupted.</b> Clear the cache using
  # ResponsibleMarkup::clear_cache if that seems to be the case.
  class ParsingError < Exception; end
  
  # Clears the cache of validation results from the system temp directory.
  #
  # Don't name anything important <tt>responsible_markup.*</tt> and keep it in
  # the temp directory.
  def self.clear_cache
    Dir.glob(File.join(Dir.tmpdir, "#{CACHE_FILENAME_STEM}*")) do |filename|
      File.delete(filename)
    end
  end

  @@validator_uri = W3C_VALIDATOR
  # Change the URI which ResponsibleMarkup uses to validate (X)HTML.
  #
  # While ResponsibleMarkup does cache the results of a validation request, any
  # decently-sized project will require a large number of validations on
  # documents which change drastically during the development process. To speed
  # up the testing process, and also to reduce the load on the W3C servers, it
  # is recommended that you install a local copy of the W3C Validator.
  #
  # To install the W3C Validator on a local server, follow these instructions:
  # http://validator.w3.org/docs/install.html
  #
  # To use a local validator, follow this example:
  #   require 'test/unit'
  #   
  #   class ValidityTest < Test::Unit::TestCase
  #     ResponsibleMarkup::validator_uri = 'http://127.0.0.1/validator/check'
  #    
  #     def setup
  #       html_content = generated_by_magic_process(:go_go_xhtml)
  #     end
  #   
  #     def test_validity
  #       assert_valid_html(html_content, "http://foo/bar/squee isn't valid XHTML")
  #     end
  #   end
  def self.validator_uri=(new_uri)
    @@validator_uri = new_uri
  end
  def self.validator_uri #:nodoc:
    @@validator_uri
  end
  
  # :call-seq:
  #   assert_compatible_empty_elements
  #   assert_compatible_empty_elements(response [, message])
  #   assert_compatible_empty_elements(string [, message])
  #
  # Asserts that the document has no empty elements (e.g., <tt><img /></tt> or
  # <tt><br /></tt>) which do not have trailing spaces (e.g. <tt><br /></tt> vs.
  # <tt><br/></tt>) or which are in the XML style (e.g., <tt><br></br></tt>).
  # Raises an informative error if any are found. See the
  # {W3C XHTML 1.0 Recommendation}[http://www.w3.org/TR/xhtml1/#C_2] for
  # rationale and explanation. This applies to XHTML *only*.
  #
  # Please note that this test doesn't search for only level one elements, but
  # treats all elements the same.
  def assert_compatible_empty_elements(response = @response, message = MSG_EMPTY_ELEMENTS)
    content = response_to_string(response)
    scan_format_and_raise([/<([\w-]+)><\/(\1)>/m, /<[^<>]+[\S]\/>/m], content, message)
  end
  
  # :call-seq:
  #   assert_content_type
  #   assert_content_type(response [,message])
  #   assert_content_type(string [, message])
  #   assert_content_type(options [, message])
  #
  # Assert that the document's content type (as indicated in the
  # <meta http-equiv> element) matches the specified content type. If checking
  # a response, it also asserts that the content type of the document matches
  # the content type specified in the HTTP headers.
  #
  # If passing an options hash, the following keys are meaningful:
  #
  # [<tt>:content</tt>] The string being checked
  # [<tt>:content_type</tt>] The expected content type. This can be a String, in
  # which case the content type of the document is compared with the string. It
  # can also be a Hash, in which case the expected content type is generated
  # based on two keys, <tt>:mime_type</tt> and <tt>:charset</tt>.
  #
  # By default, +assert_content_type+ assumes that documents should be
  # <tt>text/html; charset=utf-8</tt>. All comparisons are made without regard
  # to whitespace or case.
  #
  # When checking a response within a functional test, +assert_content_type+
  # will also compare the +Content-Type+ value in the HTTP headers, and will
  # raise an error if the header value does not match the +http-equiv+ value.
  #
  #   assert_content_type                                                     # assert that the response's content type is text/html; charset=utf-8
  #   assert_content_type :mime_type => 'text/html', :charset => 'utf-8'      # same as above
  #   assert_content_type :charset => 'utf-16'                                # assert that the response's content type is text/html; charset=utf-16
  #   assert_content_type :content_type => 'application/xml; charset=MOO15'   # assert that the response's content type matches the specified string
  #   assert_content_type :content => a_string, :charset => 'UTF-7'           # assert that a_string has a content type of text/html; charset=MOO15
  def assert_content_type(param = @response, message = MSG_CONTENT_TYPE_ERROR)
    options = param_to_options(param, { :content_type => { :mime_type => 'text/html', :charset => 'utf-8' } })
    options[:content_type][:mime_type] = options[:mime_type] if options[:mime_type]
    options[:content_type][:charset] = options[:charset] if options[:charset]
  
    if options[:content_type].is_a?(Hash)
      # create a content type based on the hash contents
      raise ArgumentError.new('an empty content type was specified') if options[:content_type].empty?
      expected_content_type = "#{options[:content_type][:mime_type]}"
      expected_content_type += "; charset=#{options[:content_type][:charset]}" if options[:content_type][:charset]
    else
      # reduce whitespace down to a single space
      expected_content_type = options[:content_type].to_s
    end
    content = options[:content]
    match = content.to_s.match(/<meta[\s]+http-equiv=['"]content-type['"][\s]+content=(['"])(.+)(\1).*>/i)
    clean_assert_block(build_message(message, MSG_CONTENT_TYPE_NONE, expected_content_type)) { !match.nil? && match.size >=2 }
    actual_meta_content_type = match[2].to_s
    
    clean_assert_block(build_message(message, MSG_CONTENT_TYPE_MISMATCH, expected_content_type, actual_meta_content_type)) do
      equal_without_case_or_whitespace?(expected_content_type, actual_meta_content_type)
    end
    
    if options[:headers] && !options[:headers].empty? && options[:headers]['Content-Type']
      actual_headers_content_type = options[:headers]['Content-Type'].to_s
      clean_assert_block(build_message(message, MSG_CONTENT_TYPE_HTTP_MISMATCH, expected_content_type, actual_headers_content_type)) do
        equal_without_case_or_whitespace?(expected_content_type, actual_headers_content_type)
      end
    end
  end
  
  # :call-seq:
  #   assert_doctype
  #   assert_doctype(string [, message])
  #   assert_doctype(symbol [, message])
  #   assert_doctype(response [, message])
  #   assert_doctype(options [, message])
  #
  # Assert that the document has a doctype.
  #
  # If passing an options hash, the following keys are meaningful:
  #
  # [<tt>:content</tt>] The string being checked
  # [<tt>:doctype</tt>] The expected doctype.
  #
  # <tt>:doctype</tt> can be a String, a Symbol, or an Array. If a String, the
  # actual doctype of the document is compared against it. If a Symbol,
  # <tt>:doctype</tt>'s entry in DEFAULT_DOCTYPES is compared against
  # the document's doctype. If an Array, <tt>:doctype</tt> will try each entry
  # of the Array. If no match is found, the assertion will fail.
  #
  # For the truly lazy, passing <tt>:any</tt> as the <tt>:doctype</tt> will simply
  # ensure that the document has a doctype.
  #
  #   assert_doctype                                               # assert that the response has a doctype
  #   assert_doctype(:any)                                         # same as above
  #   assert_doctype(:html_401_strict)                             # assert that the response is HTML 4.01 Strict
  #   assert_doctype([:html_401_Strict, :html_401_Frameset])       # assert that the response is either HTML 4.01 Strict or Frameset
  #   assert_doctype(a_string)                                     # assert that a_string has a doctype
  #   assert_doctype(:doctype => 'a doctype')                      # assert that the response has a doctype of 'a doctype'
  #   assert_doctype(:content => a_string, :doctype => :xhtml_11)  # assert that a_string is XHTML 1.1
  def assert_doctype(param = @response, message = MSG_DOCTYPE_ERROR)
    options = param_to_options(param, { :doctype => :any }, :doctype)
    content, doctype = options[:content], options[:doctype]
  
    # parse out doctype
    actual_doctype = content.to_s.match(/(<\?xml.+\?>)?[\s]*(<!DOCTYPE[^>]+>)/m)
    # strip whitespace down to basics
    actual_doctype = actual_doctype[2] if actual_doctype
    if doctype.is_a?(Symbol)
      if doctype == :any
        clean_assert_block(build_message(message,'Any doctype expected but none found.')) { !actual_doctype.nil? && !actual_doctype.empty? }
      elsif DEFAULT_DOCTYPES.include?(doctype)
        clean_assert_equal(DEFAULT_DOCTYPES[doctype], actual_doctype.to_s, message, true)
      else
        raise ArgumentError.new("Doctype <#{doctype.inspect}> isn't a recognized default doctype.")
      end
    elsif doctype.is_a?(Array)
      matches = doctype.reject do |expected_doctype|
        begin
          assert_doctype({ :content => content, :doctype => expected_doctype },message)
          false
        rescue Test::Unit::AssertionFailedError
          true
        end
      end
      clean_assert_block(build_message(message, 'Expected doctypes were <?> but actual doctype was <?>',doctype, actual_doctype.to_s)) { !matches.empty? }
    elsif doctype.is_a?(String)
      clean_assert_equal(doctype, actual_doctype, message, true)
    else
      raise ArgumentError("Can't figure out how to check the doctype of <#{doctype.inspect}>")
    end
  end
  
  # :call-seq:
  #   assert_has_xml_prolog
  #   assert_has_xml_prolog(response [, message])
  #   assert_has_xml_prolog(string [, message])
  #
  # Assert that the document begins with a well-formed XML 1.0 prolog.
  def assert_has_xml_prolog(param = @response, message = MSG_NO_XML_PROLOG)
    options = param_to_options(param)
    # If there is an XML spec beyond 1.0, this will need to change.
    # Otherwise, penalize the freaks who think XML 2.0 is substantially cooler
    # than plain ol' 1.0.
    clean_assert_block(build_message(message)){ options[:content].to_s =~ /^<\?xml[\s]+version=['"]1\.0['"].*\?>\n/ }
  end
  
  # :call-seq:
  #   assert_no_empty_attributes
  #   assert_no_empty_attributes(string [, message])
  #   assert_no_empty_attributes(response [, message])
  #   assert_no_empty_attributes(options [, message])
  #
  # Asserts that the document has no empty required attributes (e.g.,
  # <tt>alt=""</tt>). Raises an informative error if any are found. By default,
  # this scans for the required attributes in +REQUIRED_ELEMENT_ATTRIBUTES+, but
  # exceptions can be made by passing an array of allowed empty attributes via
  # <tt>:allowed</tt>.
  #
  # (The required attributes this method checks for are specific to XHTML 1.0
  # strict, but are good form regardless of the document type.)
  #
  # If passing an options hash, the following keys are meaningful:
  #
  # [<tt>:content</tt>] The string being checked
  # [<tt>:allowed</tt>] An array of attributes which are allowed to be empty
  # [<tt>:only</tt>]    An array of attributes which will be exclusively checked
  #
  #   assert_no_empty_attributes                                          # check the current response for empty attributes
  #   assert_no_empty_attributes(my_string)                               # check a string for empty attributes
  #   assert_no_empty_attributes(:allowed => ['summary', 'alt'])          # ignore empty summary attributes
  #   assert_no_empty_attributes(:only => ['alt'])                        # check for only empty alt attributes
  #   assert_no_empty_attributes(:content => a_string, :only => ['alt'])  # check for only empty alt attributes within a string
  #   assert_no_empty_attributes(@response, 'custom message')             # fail with a custom message
  def assert_no_empty_attributes(param = @response, message = MSG_EMPTY_ATTRIBUTES)
    options = param_to_options(param, { :allowed => [], :only => REQUIRED_ELEMENT_ATTRIBUTES })
    needed_attributes = (options[:only] - options[:allowed]).join('|')
    scan_format_and_raise(Regexp.new("<[^>]*(#{needed_attributes})[\s]*=[\s]*\"[\s]*\"[^<]*>", Regexp::MULTILINE | Regexp::IGNORECASE), options[:content], message)
  end
  
  # :call-seq:
  #   assert_no_long_style_attributes
  #   assert_no_long_style_attributes(response [, message])
  #   assert_no_long_style_attributes(string [, message])
  #   assert_no_long_style_attributes(options [, message])
  #
  # Asserts that the document has no +style+ attributes which are overly long
  # (default > 20 characters). Raises an informative error if any are found.
  #
  # <i>N.B. If you have that much stuff in a +style+ attribute, it deserves its
  # own CSS class.</i>
  #
  # If passing an options hash, the following keys are meaningful:
  #
  # [<tt>:content</tt>] The string being checked
  # [<tt>:max</tt>] The maximum length of the contents of a +style+ attribute
  #
  #   assert_no_long_style_attributes
  #   assert_no_long_style_attributes(:max => 40)
  #   assert_no_long_style_attributes(a_string, 'Custom message')
  #   assert_no_long_style_attributes(:content => a_string, :max => 40)
  #   assert_no_long_style_attributes({ :content => a_string, :max => 40 }, 'Custom message')
  def assert_no_long_style_attributes(param = @response, message = MSG_LONG_STYLE_ATTRIBUTES)
    options = param_to_options(param, { :max => MAX_STYLE_ATTRIBUTE_LENGTH })
    if options[:max]
      raise ArgumentError.new('maximum length must be a positive integer') if options[:max].to_i <= 0
    else
      options[:max] = MAX_STYLE_ATTRIBUTE_LENGTH
    end
    expression = Regexp.new("<[^>]+style=(\"[^\"]{#{options[:max]},}\")([^>]*)>", Regexp::MULTILINE | Regexp::IGNORECASE)
    scan_format_and_raise(expression, options[:content], message)
  end
  
  # Assert that +content+ has unobtrusive Javascript, if any. This assertion
  # will fail if +content+ has any:
  #
  # * +a+ elements with stubbed +href+ attributes (e.g., <tt><a href="#"></tt>)
  # * +a+ elements with Javascript in the +href+ attribute
  # * Elements with inline Javascript events (e.g.,
  #   <tt><div onclick="etc"></tt>)
  # * +script+ elements within the +body+ element
  
  # :call-seq:
  #   assert_unobtrusive_javascript
  #   assert_unobtrusive_javascript(response [, message])
  #   assert_unobtrusive_javascript(string [, message])
  #   assert_unobtrusive_javascript(options [, message])
  #
  # Asserts that the document does not have Javascript mixed into the markup.
  #
  # If passing an options hash, the following keys are meaningful:
  #
  # [<tt>:content</tt>] The string being checked
  # [<tt>:allowed</tt>] An array of obtrusive Javascript indicators which will
  #                     not be checked for. Possible values are:
  #
  #                     [<tt>:blank_hrefs</tt>] +a+ elements with +href+
  #                                             attributes that have an empty
  #                                             URI fragment in them (i.e.,
  #                                             <tt>#</tt>).
  #
  #                     [<tt>:javascript_hrefs</tt>] +a+ elements with +href+
  #                                                  attributes that have URIs
  #                                                  with the
  #                                                  <tt>javascript</tt>
  #                                                  protocol (e.g.,
  #                                                  <tt>href="javascript:etc."</tt>.)
  #
  #                     [<tt>:inline_events</tt>] Elements which have any of the
  #                                               +oneventname+-style events in
  #                                               them.
  #
  #                     [<tt>:script_elements_in_body</tt>] +script+ elements
  #                                                         inside the +body+
  #                                                         element, instead of
  #                                                         the +head+.
  #
  #                     By default, +assert_unobtrusive_javascript+ checks for
  #                     all of these.
  # Javascript best practices can be found in the lovely
  # <i>{DOM Scripting}[http://www.amazon.com/gp/product/1590595335/]</i> by Jeremy
  # Keith.
  #
  #   assert_unobtrusive_javascript
  #   assert_unobtrusive_javascript(:allowed => [:blank_hrefs])
  #   assert_unobtrusive_javascript(a_string)
  #   assert_unobtrusive_javascript(:content => a_string, :allowed => [:inline_events])
  #   assert_unobtrusive_javascript({ :content => a_string, :allowed => [:inline_events] }, 'Custom message')
  def assert_unobtrusive_javascript(param = @response, message = MSG_OBTRUSIVE_JAVASCRIPT)
    options = param_to_options(param, { :allowed => [] })
    content = options[:content]
    allowed = options[:allowed]
    raise ArgumentError('allowed javascript elements must be an Array') unless allowed.is_a?(Array)
    matches = scan((OBTRUSIVE_JAVASCRIPTS.keys - allowed - [:script_elements_in_body]).map{|e|OBTRUSIVE_JAVASCRIPTS[e]}, content)
    unless allowed.include?(:script_elements_in_body)
      # This is a special case, since we need to get the body *first*, and *then* check it for
      # script elements. I realize I could do it with a single regex, but it'd match the entire
      # contents of any body element with a script element, which would make for a crappy
      # error message. Still, it prompted a nice refactor of the scanning and raising
      # methods.
      if md = content.match(/<body[^<>]*>(.+)<\/body>/im)
        matches += scan(OBTRUSIVE_JAVASCRIPTS[:script_elements_in_body], md.to_s)
      end
    end
    raise_informatively(message, matches)
  end

  # :call-seq:
  #   assert_valid_html
  #   assert_valid_html(response [, message])
  #   assert_valid_html(string [, message])
  #
  # Asserts the validity of an (X)HTML document. The document is sent to the
  # {W3C Validator}[http://validator.w3.org] by default, and the results are
  # cached in system temp directory. To change the validator, refer to
  # <tt>validator_uri=</tt>.
  #
  #   assert_valid_html
  #   assert_valid_html(test_response)
  #   assert_valid_html(a_string)
  #   assert_valid_html(@response, "'/welcome' is invalid HTML.')
  def assert_valid_html(response = @response, message = MSG_INVALID_XHTML)
    content = response_to_string(response)
  
    # validate using W3C, but pull from cache if we've got it
    filename = cache_filename(content)
    unless File.exist?(filename)
      begin
        uri = URI.parse(@@validator_uri)
        validator_response = Net::HTTP.start(uri.host, uri.port).post2(uri.path, "fragment=#{CGI.escape(content)}&output=xml") 
        File.open(filename, 'w+') { |f| Marshal.dump(validator_response, f) }
      rescue => e
        raise ConnectionError.new("Couldn't connect to the validator: #{e.message}")
      end
    else
      validator_response = File.open(filename) { |f| Marshal.load(f) }
    end

    unless validator_response.is_a?(Net::HTTPSuccess)
      raise ConnectionError.new("Couldn't connect to the validator: HTTP Error #{validator_response.code} #{validator_response.message}")
    end
    
    # parse body into components
    begin
      xml_doc = REXML::Document.new(validator_response.body)
    rescue => e
      raise ParsingError.new("Couldn't parse the results from the W3C Validator: #{e.message}")
    end
    
    # parse errors into nice, palatable messages
    # (it'd be nice to abstract this into the main formatting section, but the data is just too different.)
    messages = Array.new
    lines = content.split("\n")
    xml_doc.elements.each("//messages/msg") do |msg|
      messages << "Line #{msg.attributes['line']}, Column #{msg.attributes['col']}: #{msg.text}"
      line = lines[msg.attributes['line'].to_i-1].to_s
      line_to_display, column = excerpt(line.strip, msg.attributes['col'].to_i)
      column = msg.attributes['col'].to_i - column - (line.size - line.lstrip.size)
      messages << "  #{line_to_display}"
      messages << "  #{' ' * column}^"
    end
    
    # do the actual assertion
    messages = messages.map{|x|"  #{x}"}.join("\n")
    clean_assert_block("#{message}\n#{messages}"){ xml_doc.elements["//meta/errors"].text == '0 error' }
  end
  alias :assert_valid_xhtml :assert_valid_html
  
  # :call-seq:
  #   assert_well_formed_xml
  #   assert_well_formed_xml(response [, message])
  #   assert_well_formed_xml(string [, message])
  #
  # Asserts the well-formedness of an XML document.
  # 
  # <b>N.B.:</b> This does *not* mean the XML document is valid, but rather that
  # the document can be parsed. Validity must be assessed in reference to a DTD
  # which specifies which elements go where.
  def assert_well_formed_xml(response = @response, message = MSG_INVALID_XML)
    content = response_to_string(response)
    errors = Array.new
    begin
      document = REXML::Document.new(content)
      document.root
    rescue REXML::ParseException => e
      errors = e.to_s.split("\n")  
      errors = errors.slice(errors.index('...')+1, errors.size-1)      
      message = [message, '-' * message.size, errors.map{ |e| "  " << e.capitalize}].flatten.join("\n")
    end
    clean_assert_block(message){ errors.empty? }
  end
  
private

  def cache_filename(content)
    File.join(Dir.tmpdir, CACHE_FILENAME_STEM + Digest::MD5.hexdigest(@@validator_uri+content))
  end
  
  def response_to_string(response)
    content = response.respond_to?(:body) ? response.body.to_s : response.to_s
    raise ArgumentError.new("can't check a blank string") if content.empty?
    return content
  end
  
  def param_to_options(param, defaults = {}, default_param = nil)
    options = Hash.new
    if param.respond_to?(:body) && param.respond_to?(:headers)
      options[:content] = param.body.to_s
      options[:headers] = param.headers
    elsif param.is_a?(String)
      options[:content] = param
    elsif param.is_a?(Hash)
      options = param
      if @response && @response.respond_to?(:body) && !options[:content]
        options[:content] = @response.body
        options[:headers] = @response.headers
      end
    elsif default_param
      options[default_param] = param
      if @response && @response.respond_to?(:body) && !options[:content]
        options[:content] = @response.body
        options[:headers] = @response.headers
      end
    else
      raise ArgumentError.new("can't interpret first parameter <#{param.inspect}>")
    end
    raise ArgumentError.new("can't check a blank string") if options[:content].to_s == ''
    return defaults.merge(options)
  end

  # Scan, format, and raise. Yes.
  def scan_format_and_raise(expression, content, message)
    raise_informatively(message, scan(expression, content))
  end
  
  # Blows up well.
  def raise_informatively(message, matches)
    clean_assert_block("#{message}\n#{format_match(matches)}"){ matches.empty? }
  end

  # Converts an offset into a line and column number.
  # May go totally wonky on output with CR\LF line endings.
  def offset_to_location(offset, lines)
    lines = lines.split("\n").map{ |line| line.split(//) } unless lines.is_a?(Array)
    offset_counter = 0
    current_line = 0
    while offset_counter <= offset && current_line < lines.size
      offset_counter += lines[current_line].size
      current_line += 1
    end
    # TODO: this pukes when run on Windows.
    # Tough titty, or to be fixed?
    return { :line => current_line, :column => offset - (offset_counter - lines[current_line-1].size) }
  end
  

  # Finds all instances of +expression+ within +content+ and returns a hash
  # of matches with subkeys <tt>:line</tt>, <tt>:column</tt>, <tt>:excerpt</tt>,
  # and <tt>:offset</tt>
  def scan(expression, content)
    if expression.is_a?(Array)
      matches = expression.map{ |e| scan(e, content) }.flatten
    else
      lines = content.split("\n").map{ |line| line.split(//) }
      matches = Array.new
      
      s = StringScanner.new(content)
      while s.scan_until(expression)
        
        location = offset_to_location(s.pos+1, lines)
        matches << {
          :excerpt => excerpt(s.matched, 1, 40).first,
          :offset => s.pos+1,
          :line => location[:line],
          :column => location[:column]
        }
      end
    end

    if !matches.empty? && matches.first[:offset]
      # remove all matches which occur more than once
      matches.reject!{ |m| matches.select{|x| x[:offset] == m[:offset] }.size > 1 }
      # sort the bastards
      matches.sort!{ |a,b| a[:offset] <=> b[:offset]} 
    end    

    return matches
  end
  
  # Turns match information into a happy message.
  def format_match(match)
    if match.is_a?(Array)
      match.map{ |m| format_match(m) }.flatten.map{|x|"  #{x}"}.join("\n")
    else
      ["Line #{match[:line]}, Column #{match[:column]}:"]+
      ["  #{match[:excerpt]}\n"]
    end
  end
  
  # Excerpts a string based on a position in the string, and returns
  # both the excerpt and the offset (used for caret positioning).
  def excerpt(text, position, radius = 20, excerpt_string = '...')  
    # Adapted from the Rails source.
    start_pos = [ position - radius, 0 ].max
    end_pos   = [ position + 10 + radius, text.size ].min
    prefix  = start_pos > 0 ? excerpt_string : ""
    postfix = end_pos < text.size ? excerpt_string : ""
    return (prefix + text[start_pos..end_pos].strip + postfix), (start_pos - prefix.size)
  end
  
  def equal_without_case_or_whitespace?(a, b)
    a.to_s.downcase.gsub(/[\s]/,'') == b.to_s.downcase.gsub(/[\s]/,'')
  end
  
  # Lifted from the Rails source.
  def clean_backtrace(&block)
    yield
  rescue Test::Unit::AssertionFailedError => e         
    path = File.expand_path(__FILE__)
    raise Test::Unit::AssertionFailedError, e.message, e.backtrace.reject { |line| File.expand_path(line) =~ /#{path}/ }
  end
  
  def clean_assert_block(message, &block)
    clean_backtrace do
      assert_block(message) { block.call }
    end
  end
  
  def clean_assert_equal(a, b, message, ignore_case_and_whitespace = false)
    clean_backtrace do
      if ignore_case_and_whitespace && !a.nil? && !b.nil?
        assert_equal(a.downcase.gsub(/[\s]/,''), b.downcase.gsub(/[\s]/,''), message)
      else
        assert_equal((a.nil? ? '' : a), (b.nil? ? '' : b), message)
      end
    end
  end

end

module Test #:nodoc
  module Unit #:nodoc
    class TestCase #:nodoc
      include ResponsibleMarkup #:nodoc
    end
  end
end
