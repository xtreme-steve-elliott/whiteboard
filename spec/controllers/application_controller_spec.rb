require 'spec_helper'

describe StandupsController do
  it "does not redirect to login if coming from an authorized ip" do
    FactoryGirl.create(:standup, ip_addresses_string: "127.0.0.1/32")
    allow(request).to receive(:remote_ip).and_return('127.0.0.1')
    get :index
    response.should_not be_redirect
  end

  it "requires authentication for invalid IP" do
    FactoryGirl.create(:standup, ip_addresses_string: "127.0.0.1/32")
    allow(request).to receive(:remote_ip).and_return('')
    get :index
    response.should be_redirect
    expect(response).to redirect_to 'http://test.host/auth/google_apps'
  end
end
