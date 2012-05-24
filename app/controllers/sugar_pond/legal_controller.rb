class SugarPond::LegalController < ApplicationController
  caches_page [:tos, :privacy]
  
  def tos
  end
  
  def privacy
  end
end
