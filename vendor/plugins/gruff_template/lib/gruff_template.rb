# GruffTemplate

class GruffTempPlugin
  class Template < ActionView::TemplateHandler 
    include ActionView::TemplateHandlers::Compilable
    
    def compile(template)
      <<-EOV
      begin
        #{template.source}
      
        if @graph
          @graph.to_blob
        end
        
      rescue Exception => e
        RAILS_DEFAULT_LOGGER.warn("Exception \#{e} \#{e.message} with class \#{e.class.name} thrown when rendering graph")
        raise e
      end
      EOV
    end
  end
end


          
