class RootController < ApplicationController
  def index
    redirect_to Journey::SiteOptions.site_root(logged_in?), :status => 307
  end
  
  def dashboard
    return index unless logged_in?
    
    @roles = logged_in_person.roles
    perm_conds = "person_id = #{logged_in_person.id}"
    if @roles.length > 0
      perm_conds << " OR role_id IN (#{@roles.collect {|r| r.id}.join(",")})"
    end
    
    @my_questionnaires = Questionnaire.all(:order => "id DESC",
                                        :conditions => perm_conds, :joins => :permissions).uniq
    
    @new_questionnaires = Questionnaire.all(:conditions => { :publicly_visible => true, :is_open => true },
                                            :order => "published_at DESC", :limit => 8)
    
    @responses = Response.all(:conditions => { :person_id => logged_in_person.id }, 
                          :include => { :questionnaire => nil }, :order => "created_at DESC", :limit => 8)
  end
end
