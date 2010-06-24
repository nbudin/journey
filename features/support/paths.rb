module NavigationHelpers
  def find_questionnaire(title)
    Questionnaire.find_by_title(title)
  end
  
  def find_response(questionnaire_title, response_nth)
    find_questionnaire(questionnaire_title).responses[response_nth.to_i - 1]
  end
  
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the new questionnaire page/
      new_questionnaire_path
    when /the responses page for \"([^\"]*)\"/
      responses_path(find_questionnaire($1))
    when /the response page for response \#(\d+) for \"([^\"]*)\"/
      r = find_response($2, $1)
      response_path(r.questionnaire, r)
    when /the response editing page for response \#(\d+) for \"([^\"]*)\"/
      r = find_response($2, $1)
      edit_response_path(r.questionnaire, r)
    when /the login page/
      url_for(:controller => "auth", :action => "login")

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
