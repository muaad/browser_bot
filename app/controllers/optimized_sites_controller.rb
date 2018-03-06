class OptimizedSitesController < ApplicationController
  before_action :set_optimized_site, only: [:show, :edit, :update, :destroy]

  # GET /optimized_sites
  # GET /optimized_sites.json
  def index
    @optimized_sites = OptimizedSite.all
  end

  # GET /optimized_sites/1
  # GET /optimized_sites/1.json
  def show
  end

  # GET /optimized_sites/new
  def new
    @optimized_site = OptimizedSite.new
  end

  # GET /optimized_sites/1/edit
  def edit
  end

  # POST /optimized_sites
  # POST /optimized_sites.json
  def create
    @optimized_site = OptimizedSite.new(optimized_site_params)

    respond_to do |format|
      if @optimized_site.save
        format.html { redirect_to @optimized_site, notice: 'Optimized site was successfully created.' }
        format.json { render :show, status: :created, location: @optimized_site }
      else
        format.html { render :new }
        format.json { render json: @optimized_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /optimized_sites/1
  # PATCH/PUT /optimized_sites/1.json
  def update
    respond_to do |format|
      if @optimized_site.update(optimized_site_params)
        format.html { redirect_to @optimized_site, notice: 'Optimized site was successfully updated.' }
        format.json { render :show, status: :ok, location: @optimized_site }
      else
        format.html { render :edit }
        format.json { render json: @optimized_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /optimized_sites/1
  # DELETE /optimized_sites/1.json
  def destroy
    @optimized_site.destroy
    respond_to do |format|
      format.html { redirect_to optimized_sites_url, notice: 'Optimized site was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_optimized_site
      @optimized_site = OptimizedSite.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def optimized_site_params
      params.require(:optimized_site).permit(:name, :root_url, :action, :enabled, :implementation)
    end
end
