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

  it 'has a closing message' do
    standup = FactoryGirl.create(:standup, closing_message: 'Yay')
    standup.closing_message.should == 'Yay'
  end

  it "allows mass assignment" do
    expect {
      Standup.new(
          title: "Berlin",
          to_address: "berlin+standup@pivotallabs.com",
          subject_prefix: "[FOO]",
          ip_key: "london",
          closing_message: "Go Running.",
          time_zone_name: "Mountain Time (US & Canada)"
      )
    }.to_not raise_exception
  end
end
