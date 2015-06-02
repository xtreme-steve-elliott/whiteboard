require "spec_helper"

describe StandupService do
  let(:service) { StandupService.new }

  describe "#create" do
    let(:default_attributes) { HashWithIndifferentAccess.new FactoryGirl.attributes_for(:standup) }

    it "creates a standup with the given attributes" do
      standup = nil
      expect {
        standup = service.create(attributes: default_attributes)
      }.to change(Standup, :count).by(1)

      expect(standup.attributes).to include(default_attributes)
      expect(standup).to be_persisted
    end

    context "when given an ip address that is already in the ip_addresses_string" do
      it "does not change the ip_addresses_string" do
        standup = nil
        expect {
          standup = service.create(attributes: default_attributes.merge(ip_addresses_string: "127.0.0.1/32"))
        }.to change(Standup, :count).by(1)

        expect(standup.ip_addresses_string).to eq("127.0.0.1/32")
      end
    end

    context "when given an ip address that is not in the ip_addresses_string" do
      it "only adds the ip_addresses_string" do
        standup = nil
        expect {
          standup = service.create(attributes: default_attributes.merge(ip_addresses_string: "192.168.0.0/24"))
        }.to change(Standup, :count).by(1)

        expect(standup.ip_addresses).to match_array([IPAddr.new("192.168.0.0/24")])
      end
    end
  end

  describe "#update" do
    let!(:existing_standup) { FactoryGirl.create(:standup) }

    it "updates a standup with the given attributes" do
      standup = nil
      expect {
        standup = service.update(id: existing_standup.id, attributes: {title: "Updated Title"})
      }.to_not change(Standup, :count)

      expect(standup.title).to eq("Updated Title")
      expect(standup).not_to be_changed
    end

    context "when given an ip address that is already in the ip_addresses_string" do
      it "does not change the ip_addresses_string" do
        standup = nil
        expect {
          standup = service.update(id: existing_standup.id, attributes: {ip_addresses_string: "127.0.0.1/32"})
        }.to_not change(Standup, :count)

        expect(standup.ip_addresses_string).to eq("127.0.0.1/32")
      end
    end

    context "when given an ip address that is not in the ip_addresses_string" do
      it "only adds the ip_addresses_string" do
        standup = nil
        expect {
          standup = service.update(id: existing_standup.id, attributes: {ip_addresses_string: "192.168.0.0/24"})
        }.to_not change(Standup, :count)

        expect(standup.ip_addresses).to match_array([IPAddr.new("192.168.0.0/24")])
      end
    end
  end
end