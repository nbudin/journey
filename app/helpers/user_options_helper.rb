module UserOptionsHelper
  def user_options
    if logged_in?
      render_logged_in_options
    else
      render_logged_out_options
    end
  end
  
  private
  def render_options(options)
    content_tag(:ul, options.collect {|o| render_option(o)}.join("\n"), :class => "user_options")
  end
  
  def render_option(option)
    if option.conditional.nil? or option.eval_conditional(self)
      content_tag(:li) do
        link_to option.caption, option.url
      end
    else
      ""
    end
  end
  
  def render_logged_out_options()
    render_options(Journey::UserOptions.logged_out_options)
  end
  
  def render_logged_in_options()
    render_options(Journey::UserOptions.logged_in_options)
  end
end
