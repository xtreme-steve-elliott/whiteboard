require 'spec_helper'

describe SessionsController do
  it "routes to logout" do
    get("/logout").should route_to("sessions#destroy")
  end

  it "routes to create" do
    post("/auth/google_apps/callback").should route_to(:controller => "sessions", :action => "create", :provider => "google_apps")
  end
end