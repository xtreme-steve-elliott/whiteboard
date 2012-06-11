require 'spec_helper'

describe ItemsController do
  it "routes presentation" do
    get("/items/presentation").should route_to("items#presentation")
  end
end
