# GruffTemplate

require 'gruff'

class GruffTempPlugin
  class Template < ActionView::TemplateHandler 
    include ActionView::TemplateHandlers::Compilable
    
    def compile(template)
      begin
        y = YAML.parse(ERB.new(template.source).result)
        
        if(graph_class = Gruff.const_get(y['type'])) then
          if(graph_class <= Gruff::Base) then          
            g = graph_class.new(y['width'])
            y.delete('width'); y.delete('type');
            y.each { |k,v|
              if(k == 'data') then
                if(! (v.class <= Array)) then
                  v = [v]
                end
                v.each { |x|
                  g.data(x['name'], x['values'], x['color'])
                }
              elsif(k == 'theme') then
                g.send("theme_#{v}")
              else
                g.send(k+"=", v)
              end
            }
            g.to_blob
          end
        end
        
      rescue Exception => e
        RAILS_DEFAULT_LOGGER.warn("Exception #{e} #{e.message} with class #{e.class.name} thrown when rendering graph")
        raise e
      end
    end
  end
end


          
