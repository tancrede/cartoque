require 'spec_helper'

describe ConfigurationItemsObserver do
  it "should create a CI when a concrete-CI-object is saved" do
    s = Server.new(:name => "my-new-server")
    s.should be_valid
    s.configuration_item.should be_blank
    lambda { s.save }.should change(ConfigurationItem, :count).by(+1)
    s.should be_persisted
    s.reload.configuration_item.should be_present
  end

  it "should update its CI when a concrete-CI-object with an existing CI is updated" do
    s = Server.create(:name => "my-new-server")
    s.should be_persisted
    s.reload.configuration_item.should_not be_nil
    s.configuration_item.identifier.should eq "server::my-new-server" 
    s.name = "new-name"
    lambda { s.save! }.should_not change(ConfigurationItem, :count)
    s.reload.configuration_item.identifier.should eq "server::new-name"
  end

  it "should destroy its CI if real-CI-object is destroyed" do
    s = Server.create(:name => "my-new-server")
    s.should be_persisted
    s.reload.configuration_item.should_not be_nil
    lambda { s.destroy }.should change(ConfigurationItem, :count).by(-1)
  end

  it "should not bother if a model isn't a concrete-CI-object" do
    s = Setting.new(:key => "dummy")
    lambda { s.save! }.should_not change(ConfigurationItem, :count)
  end

  it "should not generate the CI twice, in any case" do
    s = Server.new(:name => "my-new-server")
    lambda { s.save! }.should change(ConfigurationItem, :count).by(+1)
    lambda { s.save! }.should_not change(ConfigurationItem, :count)
  end
end
