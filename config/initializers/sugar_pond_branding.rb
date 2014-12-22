if ENV['SUGAR_POND_BRANDING']
  require 'journey_questionnaire'

  if Rails.env == "production"
    Journey::SiteOptions.site_root_if_logged_out = "http://welcome.journeysurveys.com"
  end
  Journey::SiteOptions.footer_partial = "sugar_pond/footer"
  
  Journey::Dashboard.add_dashbox("sugar_pond/donation_dashbox", :right)
end