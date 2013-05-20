require 'spec_helper'

describe Post do
  describe 'associations' do
    it { should belong_to(:standup) }

    it { should have_many(:items) }
    it { should have_many(:public_items) }
  end

  describe "validations" do
    it { should validate_presence_of(:standup) }
    it { should validate_presence_of(:title) }
  end

  describe "#adopt_all_items" do
    let(:standup) { create(:standup) }

    it "adopts all items not associated with a post" do
      old_post = create(:post)
      claimed_item = create(:item, post: old_post)
      unclaimed_item = create(:item, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      post.items.should == [unclaimed_item]
    end

    it "does not adopt bumped items" do
      old_post = create(:post)
      claimed_item = create(:item, post: old_post)
      unclaimed_item = create(:item, standup: standup)
      bumped_item = create(:item, bumped: true, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      post.items.should == [unclaimed_item]
    end

    it "does not adopt items with a date after today" do
      item_for_today = create(:item, date: Date.today, standup: standup)
      item_for_tomorrow = create(:item, date: Date.tomorrow, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      post.items.should == [item_for_today]
    end

    it "adopts items only for same standup" do
      other_standup = create(:standup)

      item_for_other_standup = create(:item, standup: other_standup)
      unclaimed_item = create(:item, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      post.items.should == [unclaimed_item]
    end
  end

  describe '#title_for_email' do
    context 'when there is a subject prefix set' do
      let(:standup) { create(:standup, subject_prefix: '[Standup][SF]') }

      it 'prepends the subject_prefix and date' do
        post = create(:post, standup: standup, title: "With Feeling", created_at: Time.parse("2012-06-02 12:00:00 -0700"))
        post.title_for_email.should == "#{standup.subject_prefix} 06/02/12: With Feeling"
      end
    end

    context 'when there is no subject prefix set' do
      let(:standup) { create(:standup, subject_prefix: nil) }

      it 'prepends [Standup] and the date' do
        post = create(:post, standup: standup, title: "With Feeling", created_at: Time.parse("2012-06-02 12:00:00 -0700"))
        post.title_for_email.should == "[Standup] 06/02/12: With Feeling"
      end
    end
  end

  describe '#title_for_blog' do
    it 'prepends the data' do
      post = create(:post, title: "With Feeling", created_at: Time.parse("2012-06-02 12:00:00 -0700"))
      post.title_for_blog.should == "06/02/12: With Feeling"
    end
  end

  describe '#deliver_email' do
    it "sends an email" do
      post = create(:post, items: [create(:item)])
      post.deliver_email
      ActionMailer::Base.deliveries.last.to.should == [post.standup.to_address]
    end

    it "raises an error if you send it twice" do
      post = create(:post, items: [create(:item)])
      post.deliver_email
      ActionMailer::Base.deliveries.last.to.should == [post.standup.to_address]
      expect { post.deliver_email }.to raise_error("Duplicate Email")
    end
  end

  describe '#items_by_type' do
    it "orders by created_at asc" do
      post = create(:post)
      items = [ create(:item, created_at: Time.now), create(:item, created_at: 2.days.ago )]
      post.items = items
      post.items_by_type['Help'].should == items.reverse
    end
  end

  describe '#publishable_content?' do
    it "returns false when no content items" do
      post = create(:post)
      post.publishable_content?.should be_false
    end

    it "returns false when no public content items" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: false)])
      post.publishable_content?.should be_false
    end

    it "returns true when there are public content items" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: true)])
      post.publishable_content?.should be_true
    end
  end
end
