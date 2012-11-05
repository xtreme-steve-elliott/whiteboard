require 'spec_helper'

describe Item do
  let(:item) { build_stubbed(:item) }

  describe "associations" do
    it { should belong_to(:post) }
    it { should belong_to(:standup) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:standup) }
  end

  describe "kind" do
    describe "should allow valid kinds - " do
      ['New face', 'Help', 'Interesting'].each do |kind|
        it kind do
          item.kind = kind
          item.should be_valid
        end
      end
    end

    it "should not allow other kinds" do
      item.kind = "foobar"
      item.should_not be_valid
    end
  end

  describe "defaults" do
    it "defaults public to false" do
      Item.new.public.should == false
    end
  end

  describe ".events_on_or_after" do
    subject { Item.events_on_or_after(date)['Event'] }

    let(:date) { Date.parse('1/1/1970') }
    let!(:event_before_date) { create(:item, date: (date - 1.day), kind: 'Event') }
    let!(:event_after_date) { create(:item, date: (date + 1.day), kind: 'Event') }
    let!(:event_on_date) { create(:item, date: (date), kind: 'Event') }

    it { should_not include event_before_date }
    it { should include event_on_date }
    it { should include event_after_date }

    it "orders the events by date" do
      subject.should == [event_on_date, event_after_date]
    end
  end

  describe "#for_post" do
    subject { Item.for_post }

    let!(:post) { create(:post) }
    let!(:item_with_no_post_id) { create(:item, post_id: nil, kind: "Help") }
    let!(:item_with_post_id) { create(:item, post_id: post.id, kind: "Help") }

    let!(:item_not_bumped) { create(:item, bumped: false, kind: "Help") }
    let!(:bumped_item) { create(:item, bumped: true, kind: "Help") }

    let!(:item_for_today) { create(:item, date: Date.today, kind: "Help") }
    let!(:item_with_no_date) { create(:item, date: nil, kind: "Help") }
    let!(:item_for_tomorrow) { create(:item, date: Date.tomorrow, kind: "Help") }

    let!(:event_today) { create(:item, date: Date.today, kind: 'Event') }

    it "includes item with no post id" do
      should include item_with_no_post_id
      should_not include item_with_post_id
    end

    it "includes non-bumped items" do
      should include item_not_bumped
      should_not include bumped_item
    end

    it "includes items with dates, but only for today" do
      should include item_for_today
      should_not include item_for_tomorrow
      should include item_with_no_date
    end

    it "does not include events" do
      should_not include event_today
    end

    it "combines all of the above" do
      subject.should == [item_with_no_post_id, item_not_bumped, item_for_today, item_with_no_date]
    end
  end
end
