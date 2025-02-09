require 'spec_helper'

describe ConfigurationItemsController do
  before do
    controller.session[:user_id] = Factory(:user).id #authentication
    @configuration_item = Factory(:configuration_item)
  end

  it "should should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:configuration_items)
  end

  it "should should show configuration_item" do
    get :show, id: @configuration_item.to_param
    assert_response :success
  end
end
