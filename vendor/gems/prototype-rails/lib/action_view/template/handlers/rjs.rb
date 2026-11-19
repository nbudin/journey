module ActionView
  module Template::Handlers
    class RJS
      # Default format used by RJS.
      class_attribute :default_format
      self.default_format = Mime[:js]

      # Rails 6.0 passes the source as a second argument (and 6.1 requires it); 5.x passes only the template.
      def call(template, source = nil)
        source ||= template.source
        "update_page do |page|;#{source}\nend"
      end
    end
  end
end

