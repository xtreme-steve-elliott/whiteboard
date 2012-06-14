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
end