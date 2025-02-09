require 'spec_helper'

describe ApplicationsController do
  before do
    controller.session[:user_id] = Factory(:user).id #authentication
    @controller = ApplicationsController.new
    @controller.stubs(:current_user).returns(User.new)
    @request    = ActionController::TestRequest.new
    @request.stubs(:local?).returns(true)
    @application = Factory(:application)
  end

  it "should should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:applications)
  end

  it "should should get new" do
    get :new
    assert_response :success
  end

  it "should should create application" do
    lambda{ post :create, :application => @application.attributes }.should change(Application, :count)
    assert_redirected_to application_path(assigns(:application))
  end

  it "should should show application" do
    get :show, :id => @application.to_param
    assert_response :success
  end

  it "should should access the rest/xml API" do
    app_inst = ApplicationInstance.new(:name => "prod", :authentication_method => "none")
    app_inst.servers = [ Factory(:server), Factory(:virtual) ]
    @application.application_instances = [ app_inst ]
    @application.save
    get :show, :id => @application.to_param, :format => :xml
    assert_select "application>id", "#{@application.id}"
    assert_equal 1, @application.application_instances.count
    assert_select "application>application-instances>application-instance", 1
    assert_equal 2, @application.application_instances.first.servers.count
    assert_select "application>application-instances>application-instance>servers>server", 2
  end

  it "should should access an application through its identifier" do
    get :show, :id => @application.identifier, :format => :xml
    assert_select "application>id", "#{@application.id}"
  end

  it "should should get edit" do
    get :edit, :id => @application.to_param
    assert_response :success
  end

  it "should should update application" do
    put :update, :id => @application.to_param, :application => @application.attributes
    assert_redirected_to application_path(assigns(:application))
  end

  it "should should destroy application" do
    lambda{ delete :destroy, :id => @application.to_param }.should change(Application, :count).by(-1)
    assert_redirected_to applications_path
  end
end
