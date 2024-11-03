class AccessRequestsController < ApplicationController
  before_action :set_access_request, only: %i[ show edit update destroy ]

  # GET /access_requests or /access_requests.json
  def index
    @access_requests = AccessRequest.all
  end

  # GET /access_requests/1 or /access_requests/1.json
  def show
  end

  # GET /access_requests/new
  def new
    @access_request = AccessRequest.new
  end

  # GET /access_requests/1/edit
  def edit
  end

  # POST /access_requests or /access_requests.json
  def create
    @access_request = AccessRequest.new(access_request_params)

    respond_to do |format|
      if @access_request.save
        format.html { redirect_to access_requests_path, notice: "Access request was successfully created." }
        format.json { render :show, status: :created, location: @access_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @access_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /access_requests/1 or /access_requests/1.json
  def update
    respond_to do |format|
      if @access_request.update(access_request_params)
        format.html { redirect_to @access_request, notice: "Access request was successfully updated." }
        format.json { render :show, status: :ok, location: @access_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @access_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /access_requests/1 or /access_requests/1.json
  def destroy
    @access_request.destroy

    respond_to do |format|
      format.html { redirect_to access_requests_path, status: :see_other, notice: "Access request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_access_request
      @access_request = AccessRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def access_request_params
      params.fetch(:access_request, {}).permit(:patient_id, :company_id, :status)
    end    
end
