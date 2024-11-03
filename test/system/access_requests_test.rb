require "application_system_test_case"

class AccessRequestsTest < ApplicationSystemTestCase
  setup do
    @access_request = access_requests(:one)
  end

  test "visiting the index" do
    visit access_requests_url
    assert_selector "h1", text: "Access requests"
  end

  test "should create access request" do
    visit access_requests_url
    click_on "New access request"

    fill_in "Company", with: @access_request.company_id
    fill_in "Patient", with: @access_request.patient_id
    fill_in "Status", with: @access_request.status
    click_on "Create Access request"

    assert_text "Access request was successfully created"
    click_on "Back"
  end

  test "should update Access request" do
    visit access_request_url(@access_request)
    click_on "Edit this access request", match: :first

    fill_in "Company", with: @access_request.company_id
    fill_in "Patient", with: @access_request.patient_id
    fill_in "Status", with: @access_request.status
    click_on "Update Access request"

    assert_text "Access request was successfully updated"
    click_on "Back"
  end

  test "should destroy Access request" do
    visit access_request_url(@access_request)
    click_on "Destroy this access request", match: :first

    assert_text "Access request was successfully destroyed"
  end
end
