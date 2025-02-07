require 'spec_helper'

describe CronjobsController do
  render_views

  before do
    controller.session[:user_id] = Factory(:user).id #authentication
  end

  describe "GET /index" do
    it "should not display any cronjob if no filter set" do
      get :index
      assert_select "td[colspan=5]", 1
    end

    it "should display cronjobs if server is set" do
      server = Server.new(:name => "my-server")
      assert server.save
      assert Cronjob.create(:definition_location => "/etc/cron.d/crontask",
                            :frequency => "* * * * *", :server_id => server.id,
                            :command => "/bin/ls"
                           )
      assert_equal 1, server.reload.cronjobs.count
      get :index, :by_server => server.id
      assert_select "td[colspan=5]", 0
      assert_select "td", server.name
    end
  end
end
