class RemoteLinkRenderer < WillPaginate::ActionView::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

protected
  def link(text, target, attributes = {})
    super(text, target, attributes.merge(remote: @remote, method: :get))
  end
end