# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Rails 5.2 stopped giving image_tag an alt attribute derived from the file name ("not-required.png" becomes
  # "Not required"), but this app (and the jipe gem) relies on that for its icon buttons, and screen readers rely
  # on it.  This restores the old behavior.  An explicit alt (including alt: nil) still wins.
  def image_tag(source, options = {})
    options = options.symbolize_keys
    if source.is_a?(String) && !options.key?(:alt) && !source.start_with?("data:", "cid:")
      options[:alt] = File.basename(source, ".*").sub(/-[[:xdigit:]]{32,64}\z/, "").tr("-_", " ").capitalize
    end
    super(source, options)
  end

  def tag_links(questionnaire)
    safe_join questionnaire.tag_names.map { |t| link_to t, questionnaires_path(:tag => t) }, ", "
  end

  def page_title
    components = []
    if @page_title
      components << @page_title
    end
    globalnav_items.reject { |name, url| name == "Dashboard" }.reverse.each do |name, url|
      components << name
    end
    components << "Journey"
    components.join(" - ")
  end

  # by Rob Biedenharn: http://www.mail-archive.com/rubyonrails-talk@googlegroups.com/msg15305.html
  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /\Ahttp/
      abs_path = "http#{'s' if request.ssl?}://#{request.host_with_port}#{abs_path}"
    end
    abs_path
  end

  def globalnav_items
    links = []

    if person_signed_in?
      links << ["Dashboard", dashboard_path]
    end

    if request.path =~ /^\/questionnaires/
      links << ["Surveys", questionnaires_path]
      if @questionnaire and @questionnaire.id
        links << [@questionnaire.title, questionnaire_path(@questionnaire)]
      end
    elsif @globalnav_links
      @globalnav_links.each do |name, url|
        links << [name, url]
      end
    end

    links
  end

  def globalnav_links
    safe_join(globalnav_items.map { |name, url| content_tag(:li, link_to(name, url)) }, "<li>&raquo;</li>".html_safe)
  end

  def simple_format_with_html_escape(text)
    simple_format(html_escape_once(text))
  end
end
