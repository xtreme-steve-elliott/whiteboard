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

  describe "dates" do
    before do
      @utc_today = Time.now.utc.to_date
      @utc_yesterday = @utc_today - 1.day

      @standup = FactoryGirl.create(:standup, closing_message: 'Yay')
      @standup.time_zone_name = "Pacific Time (US & Canada)"
    end

    describe "#date_today" do
      it "returns the date based on the time zone" do
        Timecop.freeze(@utc_today) do
          @standup.date_today.should == @utc_yesterday
        end
      end
    end

    describe "#date_tomorrow" do
      it "returns the date based on the time zone" do
        Timecop.freeze(@utc_today) do
          @standup.date_tomorrow.should == @utc_today
        end
      end
    end
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
