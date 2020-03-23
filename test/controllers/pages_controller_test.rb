require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get simulate" do
    get pages_simulate_url
    assert_response :success
  end

end
