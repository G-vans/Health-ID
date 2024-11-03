require "test_helper"

class AccessRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @access_request = access_requests(:one)
  end

  test "should get index" do
    get access_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_access_request_url
    assert_response :success
  end

  test "should create access_request" do
    assert_difference("AccessRequest.count") do
      post access_requests_url, params: { access_request: { company_id: @access_request.company_id, patient_id: @access_request.patient_id, status: @access_request.status } }
    end

    assert_redirected_to access_request_url(AccessRequest.last)
  end

  test "should show access_request" do
    get access_request_url(@access_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_access_request_url(@access_request)
    assert_response :success
  end

  test "should update access_request" do
    patch access_request_url(@access_request), params: { access_request: { company_id: @access_request.company_id, patient_id: @access_request.patient_id, status: @access_request.status } }
    assert_redirected_to access_request_url(@access_request)
  end

  test "should destroy access_request" do
    assert_difference("AccessRequest.count", -1) do
      delete access_request_url(@access_request)
    end

    assert_redirected_to access_requests_url
  end
end
