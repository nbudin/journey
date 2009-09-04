class RootController < ApplicationController
  def index
    redirect_to Journey::SiteOptions.site_root(logged_in?), 307
  end
end
