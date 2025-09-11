class LabResultsController < ApplicationController
  before_action :authenticate_company!, only: [:new, :create]
  before_action :authenticate_patient!, only: [:my_results, :share, :revoke_share, :analyze]
  
  def new
    @lab_result = LabResult.new
    @patients = Patient.all # In production, this would be filtered
  end

  def create
    @lab_result = CredentialService.issue_lab_result(
      lab: current_company,
      patient: Patient.find(params[:lab_result][:patient_id]),
      test_data: lab_result_params
    )
    
    if @lab_result
      redirect_to company_dashboard_path, notice: 'Lab result issued successfully'
    else
      render :new, alert: 'Failed to issue lab result'
    end
  end

  def my_results
    @lab_results = current_patient.lab_results.includes(:lab).order(test_date: :desc)
  end

  def show
    @credential = Credential.find(params[:id])
    
    # Check if viewer has access
    if patient_signed_in? && @credential.holder == current_patient
      @data = JSON.parse(@credential.credential_data)
    elsif company_signed_in?
      verification = CredentialService.verify_credential(@credential.id, current_company)
      if verification[:valid]
        @data = verification[:data]
      else
        redirect_to root_path, alert: verification[:error]
      end
    else
      redirect_to root_path, alert: 'Unauthorized access'
    end
  end

  def share
    @credential = current_patient.credentials.find(params[:id])
    verifier = Company.find(params[:company_id])
    expires_in = params[:expires_in]&.to_i&.hours || 24.hours
    
    result = CredentialService.share_credential(
      @credential.id, 
      current_patient.id, 
      verifier,
      expires_in: expires_in
    )
    
    if result[:success]
      redirect_to my_results_lab_results_path, notice: 'Access granted successfully'
    else
      redirect_to my_results_lab_results_path, alert: result[:error]
    end
  end

  def revoke_share
    @credential = current_patient.credentials.find(params[:id])
    share = @credential.credential_shares.find(params[:share_id])
    
    result = CredentialService.revoke_share(
      @credential.id,
      current_patient.id,
      share.id
    )
    
    if result[:success]
      redirect_to my_results_lab_results_path, notice: 'Access revoked'
    else
      redirect_to my_results_lab_results_path, alert: result[:error]
    end
  end

  def analyze
    # Get latest lab result for analysis
    latest_result = current_patient.lab_results.order(test_date: :desc).first
    
    if latest_result
      service = HealthReasoningService.new(current_patient)
      analysis = service.analyze_new_lab_results(latest_result)
      
      Rails.logger.info "Analysis complete for patient #{current_patient.id}: #{analysis[:risk_assessment]} risk"
      
      # Store in session for display
      session[:ai_analysis] = analysis
      
      redirect_to my_results_lab_results_path, 
        notice: "AI Analysis complete! Check the terminal for detailed output. Risk Level: #{analysis[:risk_assessment]}"
    else
      redirect_to my_results_lab_results_path, 
        alert: "No lab results available for analysis"
    end
  end

  private

  def lab_result_params
    params.require(:lab_result).permit(
      :test_name, 
      :result_value, 
      :result_unit, 
      :reference_range, 
      :test_date, 
      :notes
    )
  end
end