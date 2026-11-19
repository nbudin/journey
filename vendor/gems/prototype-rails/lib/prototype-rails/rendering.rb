require 'action_view/helpers/rendering_helper'

ActionView::Helpers::RenderingHelper.module_eval do
  # (This was alias_method_chain, which Rails 5.1 removed.  The explicit alias does the same thing.)
  alias_method :render_without_update, :render

  def render(options = {}, locals = {}, &block)
    if options == :update
      update_page(&block)
    else
      render_without_update(options, locals, &block)
    end
  end
end