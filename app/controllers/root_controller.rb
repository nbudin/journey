class RootController < ApplicationController
  before_filter :get_new_questionnaires, :only => [:welcome, :dashboard]
  
  def index
    redirect_to Journey::SiteOptions.site_root(logged_in?), :status => 307
  end
  
  def welcome
  end
  
  def dashboard
    return index unless logged_in?
    
    @page_title = "Dashboard"
    
    @roles = logged_in_person.roles
    perm_conds = "person_id = #{logged_in_person.id}"
    if @roles.length > 0
      perm_conds << " OR role_id IN (#{@roles.collect {|r| r.id}.join(",")})"
    end
    
    @my_questionnaires = Questionnaire.all(:order => "id DESC",
                                        :conditions => perm_conds, :joins => :permissions).uniq
    
    @responses = Response.all(:conditions => { :person_id => logged_in_person.id }, 
                          :include => { :questionnaire => nil }, :order => "created_at DESC", :limit => 8)
  end
  
  private
  def get_new_questionnaires
    @new_questionnaires = Questionnaire.all(:conditions => { :publicly_visible => true, :is_open => true },
                                            :order => "published_at DESC", :limit => 8)
  end
end
