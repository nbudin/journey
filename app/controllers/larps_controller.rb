class LarpsController < ApplicationController
  # GET /larps
  # GET /larps.xml
  def index
    @larps = Larp.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @larps.to_xml }
    end
  end

  # GET /larps/1
  # GET /larps/1.xml
  def show
    @larp = Larp.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @larp.to_xml }
    end
  end

  # GET /larps/new
  def new
    @larp = Larp.new
  end

  # GET /larps/1;edit
  def edit
    @larp = Larp.find(params[:id])
  end

  # POST /larps
  # POST /larps.xml
  def create
    @larp = Larp.new(params[:larp])

    respond_to do |format|
      if @larp.save
        flash[:updated] = dom_id(@larp)
        format.html { redirect_to larps_path }
        format.xml  { head :created, :location => larp_path(@larp) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @larp.errors.to_xml }
      end
    end
  end

  # PUT /larps/1
  # PUT /larps/1.xml
  def update
    @larp = Larp.find(params[:id])

    respond_to do |format|
      if @larp.update_attributes(params[:larp])
        flash[:updated] = dom_id(@larp)
        format.html { redirect_to larp_path(@larp) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @larp.errors.to_xml }
      end
    end
  end

  # DELETE /larps/1
  # DELETE /larps/1.xml
  def destroy
    @larp = Larp.find(params[:id])
    @larp.destroy

    respond_to do |format|
      format.html { redirect_to larps_path }
      format.xml  { head :ok }
    end
  end
end
