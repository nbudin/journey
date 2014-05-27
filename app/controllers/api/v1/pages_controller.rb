class Api::V1::PagesController < ApiController
  respond_to :json
  load_and_authorize_resource except: [:index]
    
  def index
    scope = Page.accessible_by(current_ability)
    scope = scope.where(id: params[:ids]) if params[:ids].present?
    respond_with scope.all
  end
  
  def show
    respond_with @page.questionnaire, @page
  end
  
  def create
    @page = Page.create(params[:page])
    respond_with @page.questionnaire, @page
  end
  
  def destroy
    @page.destroy
    head :no_content
  end
  
  def update
    @page.update_attributes(params[:page])
    head :no_content
  end
end