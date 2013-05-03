module PublishHelper
  def feature_link(caption, feature_id)
    link_to_function("".html_safe + caption + " &raquo;".html_safe, "selectFeature('#{feature_id}', this);",
                     :id => "#{feature_id}_link")
  end
end
