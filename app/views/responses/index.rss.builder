xml.instruct!

resp_page_url = url_for :only_path => false, :controller => 'analyze', :action => 'responses', :id => @questionnaire.id

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title "Responses for #{@questionnaire.title}"
    xml.link resp_page_url
    xml.description "Automatic Journey feed for responses to the #{@questionnaire.title} questionnaire"

    @responses.each do |response|
      xml.item do
        xml.title response.title
        xml.link resp_page_url
        xml.description(response.special_answers.collect do |answer|
            "#{answer.question.caption}: #{answer.value}"
         end.join("<br/>\n"))
        xml.pubDate response.answers.first.updated_at.rfc2822
        xml.guid "#{resp_page_url}?response=#{response.id}"
        xml.author "Journey"
      end
    end
  end
end

