require 'spec_helper'

describe "posts", type: :request do
  let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco', subject_prefix: "[Standup][SF]", closing_message: 'Woohoo', image_folder: 'sf', image_days: ['Mon']) }

  describe "archived posts" do
    let!(:archived_post) { FactoryGirl.create(:post, standup: standup, title: "Archived Post", archived: true) }
    let!(:item) { FactoryGirl.create(:item, title: "I am helping people", post_id: archived_post.id) }

    before do
      login
      visit '/standups/1/posts/archived'
    end

    describe "clicking on a post" do
      before do
        click_link('Archived Post')
      end

      it "displays the name of the post" do
        page.should have_content "Archived Post"
      end

      it "displays items in a post" do
        page.should have_content "I am helping people"
      end
    end
  end
end
