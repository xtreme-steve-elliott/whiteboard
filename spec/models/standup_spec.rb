require 'spec_helper'

describe Standup do
  describe 'associations' do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:posts).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:to_address) }
  end

  describe "authorized domain" do
    let(:standup) { Standup.new }

    it "can check if a domain should be given access" do
      standup.authorized_domain("pivotallabs.com").should be_true
    end

    it "allows rbcon.com" do
      standup.authorized_domain("matthewkocher.com").should be_true
    end

    it "returns false if a domain is not authorized" do
      standup.authorized_domain("notauthorized.com").should be_false
    end
  end
end
