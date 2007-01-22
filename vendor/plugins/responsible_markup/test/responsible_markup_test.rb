# If you run this from anything other than the main directory
# it will be unable to load the library or the fixtures.
# So... uh... don't.
require 'test/unit'
require 'lib/responsible_markup'
require 'digest/md5'

class ResponsibleMarkupTest < Test::Unit::TestCase

  include ResponsibleMarkup

  # Utility classes and functions

  class MockTestResponse
    attr_accessor :body
    attr_accessor :headers
  end
 
  # Raise your hand if you want to type all that. Now put down your hand. 
  alias :l :lambda
  alias :assert_passes :assert_nothing_raised

  def setup
    @fixtures = Hash.new
    Dir.glob(File.join('test','fixtures','*.txt')) do |filename|
      @fixtures[File.basename(filename, '.txt').to_sym] = File.open(filename, 'r') { |f| f.read }
    end
    @response = MockTestResponse.new
  end
  
  def teardown
    ResponsibleMarkup::clear_cache
  end
  
  def load_fixture_to_response(fixture, headers = {})
    @response.body = @fixtures[fixture]
    @response.headers = headers
    puts "Warning: fixtures/#{fixture}.txt does not exist." unless @response.body
  end
  
  def assert_fails(&block)
    assert_raise Test::Unit::AssertionFailedError do
      block.call
    end
  end
  
  def assert_fails_with(message, &block)
    begin
      block.call
    rescue Test::Unit::AssertionFailedError => e
      # compare without whitespace since whitespace is for sissies
      assert_equal(message.gsub(/[\s]/,''), e.message.gsub(/[\s]/,''), 'Assertion failed with an unexpected message')
    else
      assert_block('Assertion did not fail'){ false }
    end
  end
  
  def assert_breaks(pr = nil)
    begin
      if pr
        pr.call
      else
        yield
      end
    rescue
      assert_block('Method broke'){ true }
    else
      assert_block('Method did not break'){ false }
    end
  end
  
  def assert_all_fail(*args)
    for i in 0..args.size-1
      assert_fails{ args[i].call }
    end
  end
  
  def assert_all_break(*args)
    for i in 0..args.size-1
      assert_breaks(args[i])
    end
  end
  
  def assert_all_pass(*args)
    for i in 0..args.size-1
      assert_passes do
        args[i].call
      end
    end
  end
  
  # Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  def test_assert_compatible_empty_elements
    # the good
    load_fixture_to_response(:good_empty_elements)
    assert_all_pass(
      l{ assert_compatible_empty_elements },
      l{ assert_compatible_empty_elements @response },
      l{ assert_compatible_empty_elements @response, 'message' },
      l{ assert_compatible_empty_elements @fixtures[:good_empty_elements] },
      l{ assert_compatible_empty_elements @fixtures[:good_empty_elements], 'message' }
    )
    
    # the bad
    load_fixture_to_response(:bad_empty_elements)
    assert_all_fail(
      l{ assert_compatible_empty_elements },
      l{ assert_compatible_empty_elements @response },
      l{ assert_compatible_empty_elements @response, 'message' },
      l{ assert_compatible_empty_elements @fixtures[:bad_empty_elements] },
      l{ assert_compatible_empty_elements @fixtures[:bad_empty_elements], 'message' }
    )
    
    # the neurotic
    load_fixture_to_response(:bad_empty_elements)
    assert_fails_with("Output has empty elements which may be incompatible with older browsers.\n  Line 67, Column 32:\n    <br/>\n\n  Line 89, Column 19:\n    <hr/>\n\n  Line 90, Column 4:\n    <hr></hr>\n\n  Line 92, Column 5:\n    <br></br>\n\n  Line 92, Column 23:\n    <img src=\"moo\"/>\n") do
      assert_compatible_empty_elements
    end
    assert_fails_with("Sweet lord, it's got horrible empty elements!\n  Line 67, Column 32:\n    <br/>\n\n  Line 89, Column 19:\n    <hr/>\n\n  Line 90, Column 4:\n    <hr></hr>\n\n  Line 92, Column 5:\n    <br></br>\n\n  Line 92, Column 23:\n    <img src=\"moo\"/>\n") do
      assert_compatible_empty_elements @response, "Sweet lord, it's got horrible empty elements!"
    end
  end

  
  def test_assert_content_type
    # the good
    load_fixture_to_response(:valid_xhtml_10_strict, { 'Content-Type' => 'text/html; charset=iso-8859-1' })
    assert_all_pass(
      l{ assert_content_type(:charset => 'ISO-8859-1', :mime_type => 'text/html') },
      l{ assert_content_type(:charset => 'ISO-8859-1') },
      l{ assert_content_type(:content_type => 'text/html; charset=iso-8859-1') },
      l{ assert_content_type(:content_type => 'text/html;                 charset=iso-8859-1') },
      l{ assert_content_type(:content_type => {:charset => 'ISO-8859-1', :mime_type => 'text/html'}) },
      l{ assert_content_type(:content => @fixtures[:valid_xhtml_10_strict], :charset => 'iso-8859-1') }
    )
    load_fixture_to_response(:valid_xhtml_10_strict)
    assert_all_pass(
      l{ assert_content_type(:charset => 'ISO-8859-1', :mime_type => 'text/html') },
      l{ assert_content_type(:charset => 'ISO-8859-1') },
      l{ assert_content_type(:content_type => 'text/html; charset=iso-8859-1') },
      l{ assert_content_type(:content_type => 'text/html;           charset=iso-8859-1') },
      l{ assert_content_type(:content_type => {:charset => 'ISO-8859-1', :mime_type => 'text/html'}) },
      l{ assert_content_type(:content => @fixtures[:valid_xhtml_10_strict], :charset => 'iso-8859-1') }
    )

    # the bad
    
    # meta/header mismatch
    load_fixture_to_response(:valid_xhtml_10_strict, { 'Content-Type' => 'text/html; charset=utf-8' })
    assert_all_fail(
      l{ assert_content_type(:charset => 'ISO-8859-1', :mime_type => 'text/html') },
      l{ assert_content_type(:charset => 'ISO-8859-1') },
      l{ assert_content_type(:content_type => 'text/html; charset=iso-8859-1') },
      l{ assert_content_type(:content_type => {:charset => 'ISO-8859-1', :mime_type => 'text/html'}) }
    )
    
    # meta charset mismatch
    load_fixture_to_response(:valid_xhtml_10_strict, { 'Content-Type' => 'text/html; charset=iso-8859-1' })
    assert_all_fail(
      l{ assert_content_type(:charset => 'ISO-8859-1', :mime_type => 'application/xml+xhtml') },
      l{ assert_content_type(:content_type => 'application/xml+xhtm; charset=iso-8859-1') },
      l{ assert_content_type(:content_type => {:charset => 'ISO-8859-1', :mime_type => 'application/xml+xhtm'}) }
    )
    
    # TODO: the neurotic
    load_fixture_to_response(:valid_xhtml_10_strict, { 'Content-Type' => 'text/html; charset=iso-8859-1' })
    assert_fails_with("Output content type did not match the expected content type.\nExpected content type was <\"text/html; charset=utf-8\"> but http-equiv content type was <\"text/html; charset=iso-8859-1\">.") do
      assert_content_type
    end
    assert_fails_with("Crap crap crap.\nExpected content type was <\"text/html; charset=utf-8\"> but http-equiv content type was <\"text/html; charset=iso-8859-1\">.") do
      assert_content_type({}, "Crap crap crap")
    end
    load_fixture_to_response(:valid_xhtml_10_strict, { 'Content-Type' => 'text/html; charset=utf-8' })
    assert_fails_with("Output content type did not match the expected content type.\nExpected content type was <\"text/html; charset=utf-8\"> but http-equiv content type was <\"text/html; charset=iso-8859-1\">.") do
      assert_content_type
    end
    load_fixture_to_response(:valid_xhtml_10_strict, { 'Content-Type' => 'text/html; charset=utf-8' })
    assert_fails_with("Crap crap crap.\nExpected content type was <\"text/html; charset=utf-8\"> but http-equiv content type was <\"text/html; charset=iso-8859-1\">.") do
      assert_content_type({}, 'Crap crap crap')
    end
    
    # TODO: the ugly
    assert_all_break(
      l{ assert_content_type :content => nil },
      l{ assert_content_type :content_type => nil },
      l{ assert_content_type :content_type => {} }
    )
  end

  def test_assert_doctype
    # the good
    ResponsibleMarkup::DEFAULT_DOCTYPES.each do |doctype, value|
      load_fixture_to_response("valid_#{doctype}".to_sym)
      assert_all_pass(
        l{ assert_doctype },
        l{ assert_doctype :any },
        l{ assert_doctype doctype },
        l{ assert_doctype ['moo', :any] },
        l{ assert_doctype [:any, 'moo'] },
        l{ assert_doctype ['moo', doctype] },
        l{ assert_doctype [doctype, 'moo'] },
        l{ assert_doctype @fixtures["valid_#{doctype}".to_sym] },
        l{ assert_doctype :content => @fixtures["valid_#{doctype}".to_sym], :doctype => doctype }
      )
    end
    
    # the bad
    load_fixture_to_response(:no_doctype)
    assert_all_fail(
      l{ assert_doctype },
      l{ assert_doctype :any },
      l{ assert_doctype :xhtml_11 },
      l{ assert_doctype ['moo', :any] },
      l{ assert_doctype [:any, 'moo'] },
      l{ assert_doctype ['moo', :xhtml_11] },
      l{ assert_doctype [:xhtml_11, 'moo'] },
      l{ assert_doctype @response.body },
      l{ assert_doctype :content => @response.body, :doctype => :xhtml_11 },
      l{ assert_doctype :content => @fixtures[:valid_html_401_strict], :doctype => :xhtml_11 }
    )
    load_fixture_to_response(:custom_doctype)
    assert_passes{ assert_doctype :doctype => '<!DOCTYPE    HTML     PUBLIC "-//W3C//DTD HTML 4.01 Magic Happy Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">' }
    
    # the neurotic
    load_fixture_to_response(:no_doctype)
    assert_fails_with("Output doctype does not match expected value(s).\nAny doctype expected but none found.") do
      assert_doctype :any
    end
    assert_fails_with("mooo.\nAny doctype expected but none found.") do
      assert_doctype :any, "mooo"
    end
    load_fixture_to_response(:valid_xhtml_11)
    assert_fails_with("Outputdoctypedoesnotmatchexpectedvalue(s).<\"<!doctypehtmlpublic\\\"-//w3c//dtdxhtml1.0strict//en\\\"\\\"http://www.w3.org/tr/xhtml1/dtd/xhtml1-strict.dtd\\\">\">expectedbutwas<\"<!doctypehtmlpublic\\\"-//w3c//dtdxhtml1.1//en\\\"\\\"http://www.w3.org/tr/xhtml11/dtd/xhtml11.dtd\\\">\">.") do
      assert_doctype :xhtml_10_strict
    end
    assert_fails_with("mooo.<\"<!doctypehtmlpublic\\\"-//w3c//dtdxhtml1.0strict//en\\\"\\\"http://www.w3.org/tr/xhtml1/dtd/xhtml1-strict.dtd\\\">\">expectedbutwas<\"<!doctypehtmlpublic\\\"-//w3c//dtdxhtml1.1//en\\\"\\\"http://www.w3.org/tr/xhtml11/dtd/xhtml11.dtd\\\">\">.") do
      assert_doctype :xhtml_10_strict, "mooo"
    end
    
    # the ugly
    load_fixture_to_response(:valid_xhtml_11)
    assert_all_break(
      l{ assert_doctype :something_i_can_never_have },
      l{ assert_doctype 300 }
    )
  end

  def test_assert_has_xml_prolog
    # the good
    load_fixture_to_response(:xml_with_prolog)
    assert_all_pass(
      l{ assert_has_xml_prolog },
      l{ assert_has_xml_prolog @fixtures[:xml_with_prolog] },
      l{ assert_has_xml_prolog :content => @fixtures[:xml_with_prolog] }
    )
    
    # the bad
    load_fixture_to_response(:xml_without_prolog)
    assert_all_fail(
      l{ assert_has_xml_prolog },
      l{ assert_has_xml_prolog @fixtures[:xml_without_prolog] },
      l{ assert_has_xml_prolog :content => @fixtures[:xml_without_prolog] }
    )
    
    # the neurotic
    load_fixture_to_response(:xml_without_prolog)
    assert_fails_with("Output has no XML prolog.") do
      assert_has_xml_prolog
    end
    assert_fails_with("Crappity crap crap.") do
      assert_has_xml_prolog @response, 'Crappity crap crap'
    end
    
    # the ugly
    load_fixture_to_response(:xml_without_prolog)
    assert_all_break(
      l{ assert_has_xml_prolog :moo },
      l{ assert_has_xml_prolog nil },
      l{ assert_has_xml_prolog :content => nil }
    )
  end

  def test_assert_no_empty_attributes
    # the good
    load_fixture_to_response(:has_no_empty_attributes)
    assert_all_pass(
      l{ assert_no_empty_attributes },
      l{ assert_no_empty_attributes @response },
      l{ assert_no_empty_attributes @response, 'message' },
      l{ assert_no_empty_attributes @fixtures[:has_no_empty_attributes] },
      l{ assert_no_empty_attributes @fixtures[:has_no_empty_attributes], 'message' }
    )
    
    # the bad
    load_fixture_to_response(:has_empty_attributes)
    assert_all_fail(
      l{ assert_no_empty_attributes },
      l{ assert_no_empty_attributes @response },
      l{ assert_no_empty_attributes @response, 'message' },
      l{ assert_no_empty_attributes @fixtures[:has_empty_attributes] },
      l{ assert_no_empty_attributes @fixtures[:has_empty_attributes], 'message' }
    )
    
    # the neurotic
    load_fixture_to_response(:has_empty_attributes)
    assert_fails_with("Output has empty attributes.\n  Line 52, Column 14:\n    <table class=\"header-table\" summary=\"\">\n") do
      assert_no_empty_attributes
    end
    assert_fails_with("Things have exploded.\n  Line 52, Column 14:\n    <table class=\"header-table\" summary=\"\">\n") do
      assert_no_empty_attributes @response.body, "Things have exploded."
    end
    
    # the oddly specific
    load_fixture_to_response(:has_empty_attributes)
    assert_passes{ assert_no_empty_attributes :allowed => ['summary'] }
    assert_passes{ assert_no_empty_attributes :only => ['babba'] }
    
    # the ugly
    assert_all_break(
      l{ assert_no_empty_attributes :content => nil },
      l{ assert_no_empty_attributes :i_love_jon_stewart },
      l{ assert_no_empty_attributes 300 }
    )
  end
  
  def test_assert_no_long_style_attributes
    # the good
    load_fixture_to_response(:has_no_long_style_attributes)
    assert_all_pass(
      l{ assert_no_long_style_attributes },
      l{ assert_no_long_style_attributes @response },
      l{ assert_no_long_style_attributes @response, 'message' },
      l{ assert_no_long_style_attributes @fixtures[:has_no_long_style_attributes] },
      l{ assert_no_long_style_attributes @fixtures[:has_no_long_style_attributes], 'message'}
    )
    
    # the bad
    load_fixture_to_response(:has_long_style_attributes)
    assert_all_fail(
      l{ assert_no_long_style_attributes },
      l{ assert_no_long_style_attributes @response },
      l{ assert_no_long_style_attributes @response, 'message' },
      l{ assert_no_long_style_attributes @fixtures[:has_long_style_attributes] },
      l{ assert_no_long_style_attributes @fixtures[:has_long_style_attributes], 'message'}      
    )
    
    # the neurotic
    load_fixture_to_response(:has_long_style_attributes)
    assert_fails_with("Output has overly long style attributes.\nConsider refactoring this display information into a CSS class.\n  Line 51, Column 13:\n    <div id=\"classHeader\" style=\"text-decoration: none;...\n") do
      assert_no_long_style_attributes
    end
    assert_fails_with("Overblown hoboken townsend shawl.\n  Line 51, Column 13:\n    <div id=\"classHeader\" style=\"text-decoration: none;...\n") do
      assert_no_long_style_attributes @response, 'Overblown hoboken townsend shawl.'
    end
    
    # the oddly specific
    load_fixture_to_response(:has_long_style_attributes)
    assert_passes{ assert_no_long_style_attributes :max => 3000 }
    
    # the ugly
    assert_all_break(
      l{ assert_no_long_style_attributes :three },
      l{ assert_no_long_style_attributes :max => -1 },
      l{ assert_no_long_style_attributes :max => 'yay for me' },
      l{ assert_no_long_style_attributes nil },
      l{ assert_no_long_style_attributes '' }
    )
  end
  
  def test_assert_unobtrusive_javascript
    # the good
    load_fixture_to_response(:has_unobtrusive_javascript)
    assert_all_pass(
      l{ assert_unobtrusive_javascript },
      l{ assert_unobtrusive_javascript :allowed => [] },
      l{ assert_unobtrusive_javascript :allowed => [:blank_hrefs, :javascript_hrefs, :inline_events, :script_elements_in_body] },
      l{ assert_unobtrusive_javascript @fixtures[:has_unobtrusive_javascript] },
      l{ assert_unobtrusive_javascript :content => @fixtures[:has_unobtrusive_javascript], :allowed => [] }
    )
    
    # the bad
    load_fixture_to_response(:has_crappy_javascript)
    assert_all_fail(
      l{ assert_unobtrusive_javascript },
      l{ assert_unobtrusive_javascript :allowed => [] },
      l{ assert_unobtrusive_javascript @fixtures[:has_crappy_javascript] },
      l{ assert_unobtrusive_javascript :content => @fixtures[:has_crappy_javascript], :allowed => [] }
    )
    
    # the neurotic
    load_fixture_to_response(:has_crappy_javascript)
    assert_fails_with("OutputhasJavascriptmixedintothemarkup.Line10,Column2:<bodyonload=\"do_a_bunch_of_javascript(3>Line10,Column55:<?xmlversion=\"1.0\"encoding=\"iso-8859-1\"?><!DOCTYP...Line14,Column1:<ahref=\"javascript:I,too,ambrokenbyturningJav...Line15,Column14:<divid=\"content\"onclick=\"magic_javascriptjax_2_0_b...Line12,Column10:<script>Dosomethinghere</script>") do
      assert_unobtrusive_javascript
    end
    assert_fails_with("Ohnoes!Line10,Column2:<bodyonload=\"do_a_bunch_of_javascript(3>Line10,Column55:<?xmlversion=\"1.0\"encoding=\"iso-8859-1\"?><!DOCTYP...Line14,Column1:<ahref=\"javascript:I,too,ambrokenbyturningJav...Line15,Column14:<divid=\"content\"onclick=\"magic_javascriptjax_2_0_b...Line12,Column10:<script>Dosomethinghere</script>") do
      assert_unobtrusive_javascript(@response, 'Oh noes!')
    end
    
    
    # the oddly specific
    load_fixture_to_response(:has_crappy_javascript)
    assert_passes{ assert_unobtrusive_javascript :allowed => [:blank_hrefs, :javascript_hrefs, :inline_events, :script_elements_in_body] }
    
    # the ugly
    load_fixture_to_response(:has_crappy_javascript)
    assert_all_break(
      l{ assert_unobtrusive_javascript nil },
      l{ assert_unobtrusive_javascript :allowed => 'whee' },
      l{ assert_unobtrusive_javascript :allowed => nil }
    )
  end
  
  def test_assert_valid_html
    # the good
    ResponsibleMarkup::DEFAULT_DOCTYPES.each do |doctype, value|
      load_fixture_to_response("valid_#{doctype}".to_sym)
      unless @response.body.nil? or @response.body.empty?
        assert_all_pass(
          l{ assert_valid_html },
          l{ assert_valid_xhtml },
          l{ assert_valid_html(@response, "valid_#{doctype}.txt is invalid HTML.") },
          l{ assert_valid_html(@fixtures["valid_#{doctype}".to_sym], "valid_#{doctype}.txt is invalid HTML.") },
          l{ assert_valid_xhtml(@response, "valid_#{doctype}.txt is invalid HTML.") },
          l{ assert_valid_xhtml(@fixtures["valid_#{doctype}".to_sym], "valid_#{doctype}.txt is invalid HTML.") }
        )
      end
    end
    
    # the bad
    ResponsibleMarkup::DEFAULT_DOCTYPES.each do |doctype, value|
      load_fixture_to_response("invalid_#{doctype}".to_sym)
      unless @response.body.nil? or @response.body.empty?
        assert_all_fail(
          l{ assert_valid_html },
          l{ assert_valid_xhtml },
          l{ assert_valid_html(@response, "invalid_#{doctype}.txt is invalid HTML.") },
          l{ assert_valid_html(@fixtures["invalid_#{doctype}".to_sym], "invalid_#{doctype}.txt is invalid HTML.") },
          l{ assert_valid_xhtml(@response, "invalid_#{doctype}.txt is invalid HTML.") },
          l{ assert_valid_xhtml(@fixtures["invalid_#{doctype}".to_sym], "invalid_#{doctype}.txt is invalid HTML.") }
        )
      end
    end
    
    # the neurotic

# I wish I could actually test the messages themselves, but the output differs
# slightly, as the validator seems to choose some errors over others. I can make
# damn sure that the invalid forms fail and the valid forms pass, though.

#    load_fixture_to_response(:invalid_xhtml_10_strict)
#    assert_fails_with("Output is invalid (X)HTML.\n  Line 45, Column 0: character data is not allowed here\n    Having text right here isn't va...\n    ^") do
#      assert_valid_html
#    end
#    assert_fails_with("Oh noes!\n  Line 45, Column 0: character data is not allowed here\n    Having text right here isn't va...\n    ^") do
#      assert_valid_html @response, "Oh noes!"
#    end
#    
#    load_fixture_to_response(:invalid_xhtml_10_transitional)
#    assert_fails_with("Output is invalid (X)HTML.\n  Line 49, Column 25: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...id=\"classHeader\">\n               ^\n  Line 468, Column 6: end tag for \"p\" omitted, but OMITTAG NO was specified\n    </body>\n          ^\n  Line 47, Column 0: start tag was here\n    <p>Whoah, crap, it's a paragrap...\n    ^\n  Line 78, Column 23: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...v id=\"bodyContent\">\n                         ^\n  Line 120, Column 22: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...iv id=\"includes\">\n                       ^\n  Line 128, Column 21: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...div id=\"section\">\n                       ^\n  Line 464, Column 26: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...d=\"validator-badges\">\n                           ^") do
#      assert_valid_html
#    end
#    assert_fails_with("Oh noes!\n  Line 49, Column 25: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...id=\"classHeader\">\n               ^\n  Line 468, Column 6: end tag for \"p\" omitted, but OMITTAG NO was specified\n    </body>\n          ^\n  Line 47, Column 0: start tag was here\n    <p>Whoah, crap, it's a paragrap...\n    ^\n  Line 78, Column 23: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...v id=\"bodyContent\">\n                         ^\n  Line 120, Column 22: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...iv id=\"includes\">\n                       ^\n  Line 128, Column 21: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...div id=\"section\">\n                       ^\n  Line 464, Column 26: document type does not allow element \"div\" here; missing one of \"object\", \"applet\", \"map\", \"iframe\", \"button\", \"ins\", \"del\" start-tag\n    ...d=\"validator-badges\">\n                           ^") do
#      assert_valid_html @response, "Oh noes!"
#    end
    
    # the ugly
    load_fixture_to_response(:invalid_xhtml_10_transitional)
    assert_all_break(
      l{ assert_valid_html nil },
      l{ assert_valid_html '' },
      l{ assert_valid_html {} },
      l{ assert_valid_html :moo }
    )
  end
  
  def test_assert_well_formed_xml
    load_fixture_to_response(:valid_xml)
    assert_all_pass(
          l{ assert_well_formed_xml },
          l{ assert_well_formed_xml(@response, "valid_xml.txt is invalid XML.") },
          l{ assert_well_formed_xml(@fixtures[:valid_xml], "valid_xml.txt is invalid XML.") }
    )
    
    load_fixture_to_response(:invalid_xml) 
    assert_all_fail(
          l{ assert_well_formed_xml },
          l{ assert_well_formed_xml(@response, "invalid_xml.txt is invalid XML.") },
          l{ assert_well_formed_xml(@fixtures[:invalid_xml], "invalid_xml.txt is invalid XML.") }
    )
  end

  def test_using_own_validator
    ResponsibleMarkup::validator_uri = 'totally not even close to being a uri'
    begin
      assert_raise ResponsibleMarkup::ConnectionError do
        assert_valid_html("This won't get checked, because it shouldn't be able to connect")
      end
    ensure
      ResponsibleMarkup.validator_uri = W3C_VALIDATOR
    end
  end

  def test_caching_and_clearing
    assert_nothing_raised do
      assert_valid_xhtml(@fixtures[:valid_xhtml_11], "valid_xhtml_11.txt is invalid HTML.")
    end
    assert File.exist?(cache_filename(@fixtures["valid_xhtml_11".to_sym])), "Cache file was not created where it was expected."
    ResponsibleMarkup::clear_cache
    assert !File.exist?(cache_filename(@fixtures["valid_xhtml_11".to_sym])), "Cache file was deleted after clearing the cache."
  end

end
