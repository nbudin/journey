if ENV['SUGAR_POND_BRANDING']
  require 'journey_questionnaire'

  if ENV['RAILS_ENV'] == "production"
    Journey::SiteOptions.site_root_if_logged_out = "http://welcome.journeysurveys.com"
  end
  Journey::UserOptions.hook do |nb, controller|
    nb.nav_item "Support", {:controller => "support", :action => "index"} if controller.logged_in?
  end
  Journey::SiteOptions.footer_partial = "sugar_pond/footer"
  
  Journey::Dashboard.add_dashbox("sugar_pond/donation_dashbox", :right)
end