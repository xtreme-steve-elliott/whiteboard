require 'spec_helper'

describe ApplicationHelper do
  describe "#close_standup" do
    it "picks a closing" do
      helper.should_receive(:rand).and_return(0)
      helper.standup_closing.should == "And That's The Standup"
    end
  end

  describe "#pending_post_count" do
    it "can count" do
      create(:post)
      helper.pending_post_count.should == 1
    end
  end

  describe "#show_or_edit_post_path" do
    it "links to edit if not archived" do
      post = create(:post)
      helper.show_or_edit_post_path(post).should == edit_post_path(post)
    end

    it "links to show if archived" do
      post = create(:post, archived: true)
      helper.show_or_edit_post_path(post).should == post_path(post)
    end
  end
end