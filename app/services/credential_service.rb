class CredentialService
  def self.issue_lab_result(lab:, patient:, test_data:)
    lab_result = LabResult.create!(
      lab: lab,
      patient: patient,
      test_name: test_data[:test_name],
      result_value: test_data[:result_value],
      result_unit: test_data[:result_unit],
      reference_range: test_data[:reference_range],
      test_date: test_data[:test_date],
      notes: test_data[:notes]
    )
    
    # Credential is auto-created via LabResult after_create callback
    lab_result.credential
  end

  def self.verify_credential(credential_id, verifier)
    credential = Credential.find(credential_id)
    
    # Check if credential is active
    unless credential.status == 'active'
      log_verification(credential, verifier, 'failed', reason: 'Credential not active')
      return { valid: false, error: 'Credential is not active' }
    end

    # Check if credential has expired
    if credential.expires_at && credential.expires_at < Time.current
      log_verification(credential, verifier, 'expired', reason: 'Credential expired')
      return { valid: false, error: 'Credential has expired' }
    end

    # Verify signature
    unless credential.verify_signature
      log_verification(credential, verifier, 'failed', reason: 'Invalid signature')
      return { valid: false, error: 'Invalid credential signature' }
    end

    # Check if verifier has permission to access
    share = credential.credential_shares.find_by(verifier: verifier)
    unless share && share.accessible?
      log_verification(credential, verifier, 'failed', reason: 'No access permission')
      return { valid: false, error: 'Access not granted' }
    end

    log_verification(credential, verifier, 'success')
    { valid: true, data: JSON.parse(credential.credential_data) }
  end

  def self.share_credential(credential_id, patient_id, verifier, expires_in: 24.hours)
    credential = Credential.find(credential_id)
    
    # Ensure patient owns this credential
    return { error: 'Unauthorized' } unless credential.holder_id == patient_id
    
    share = credential.share_with(verifier, expires_at: expires_in.from_now)
    { success: true, share: share }
  end

  def self.revoke_share(credential_id, patient_id, share_id)
    credential = Credential.find(credential_id)
    
    # Ensure patient owns this credential
    return { error: 'Unauthorized' } unless credential.holder_id == patient_id
    
    share = credential.credential_shares.find(share_id)
    share.revoke!
    { success: true }
  end

  private

  def self.log_verification(credential, verifier, result, details = {})
    VerificationLog.log_verification(credential, verifier, result, details)
  end
end