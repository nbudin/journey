class RootController < ApplicationController
  def index
    redirect_to Journey::SiteOptions.site_root(logged_in?)
  end
end
