xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title("New on Journey")
    desc = "The newest surveys published on Journey"
    if params[:tag] and params[:tag] != ''
      desc += " tagged as '#{params[:tag]}'"
    end
    if params[:title] and params[:title] != ''
      desc += " matching title '#{params[:title]}'"
    end
    xml.description(desc)
    xml.language("en-us")
    xml.link(url_for(params.update({:only_path => false})))
    for questionnaire in @questionnaires
      xml.item do
        xml.title(questionnaire.title)
        xml.description(questionnaire.welcome_text)
        # rfc822
        if questionnaire.updated_at
          xml.pubDate(questionnaire.updated_at.rfc2822)
        end
      xml.link(url_for(:controller => "answer", :action => "index", :id => questionnaire.id, :only_path => false))
      xml.guid(url_for(:controller => "answer", :action => "index", :id => questionnaire.id, :only_path => false))
      end
    end
  }
}