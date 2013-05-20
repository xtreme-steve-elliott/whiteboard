require 'spec_helper'

describe "publishing", type: :request, js: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'Camelot', subject_prefix: "[Standup][CO]") }

  before do
    mock_omniauth
    visit '/auth/google_apps/callback'
    visit '/'

    WordpressService.any_instance.stub(:minimally_configured?).and_return(true)
    WordpressService.any_instance.should_not_receive(:send!)
  end

  it "allows publishing to blog and email" do
    click_link(standup.title)

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    page.should have_content("Please update these items with any new information from standup:")

    page.should have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
    page.should have_content("There is no content to publish")
  end
end
