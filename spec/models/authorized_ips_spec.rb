require 'spec_helper'

describe AuthorizedIps do
  it "can tell if a ip is authorized" do
    with_authorized_ips({sf: [IPAddr.new("127.0.0.1/32")]}) do
      AuthorizedIps.authorized_ip?('127.0.0.1').should == true
    end
  end

  it "can tell what standup corresponds to an ip" do
    with_authorized_ips({nyc: [IPAddr.new("127.0.0.1/32")]}) do
      AuthorizedIps.corresponding_ip_key('127.0.0.1/32').should == "nyc"
    end
  end
end
