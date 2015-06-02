require 'spec_helper'

describe "Adding new faces", js: true do
  let!(:standup) { FactoryGirl.create(:standup, ip_addresses_string: "127.0.0.1/32") }
  let(:timezone) { ActiveSupport::TimeZone.new(standup.time_zone_name) }
  let(:date_five_days) { timezone.now + 5.days }

  it "doesn't allow start dates in the past" do
    login
    visit '/'

    click_on standup.title
    find(:css, '[data-kind="New face"]').click
    fill_in "item[title]", with: "Jane"

    fill_in "item[date]", with: "2010-01-01"

    find(:css, '[name="item[date]"]').click
    find(:css, 'td.day', text: '11').click

    expect(find_field("item[date]").value).to eq("2010-01-01")

    click_on "Create New Face"

    expect(page).to have_content "Please choose a date in present or future"
    #page.should have_content "Create New Face" #TODO: as of 2014-02-05, this captures a bug.
  end

  it "allows yesterday's new faces to post today" do
    new_face = FactoryGirl.create(:new_face, standup: standup)

    Timecop.travel(date_five_days) do
      login
      visit '/'

      click_on standup.title
      fill_in 'post[from]', with: 'Capybara'
      fill_in 'post[title]', with: 'Test Cases Rule'

      find('#create-post').click

      page.driver.browser.switch_to.alert.accept

      expect(page).not_to have_content "Unable to create post"
      expect(current_path).not_to eq(standup_items_path(standup))

      post = Post.last
      expect(post.items).to match_array([new_face])
    end
  end
end
