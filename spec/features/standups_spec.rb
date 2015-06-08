require 'spec_helper'

describe "standups", type: :request do
  before do
    login
    visit '/'
    FactoryGirl.create(:standup, ip_addresses_string: '127.0.0.1/32')

    expect(find('h2')).to have_content 'CHOOSE A STANDUP'
    click_link('New Standup')

    fill_in 'standup_title', with: 'London'
    fill_in 'standup_subject_prefix', with: '[Standup][ENG]'
    select 'Mountain Time (US & Canada)', from: 'standup_time_zone_name'
    fill_in 'standup_to_address', with: 'all@pivotallabs.com'
    fill_in 'standup_closing_message', with: 'Woohoo'
    fill_in 'standup_ip_addresses_string', with: "192.168.0.0/24\n\r192.168.1.5\n\r127.0.0.1"
    fill_in 'standup_start_time_string', with: '10:00am'
    fill_in 'standup_image_urls', with: 'http://example.com/bar.png'
    click_button 'Create Standup'

    visit '/'
    expect(page).to have_content 'LONDON'
    click_link('London')
  end

  it 'creates new standups', js: true do
    current_page = current_url
    expect(current_page).to match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
    expect(find('div.navbar-fixed-top')).to have_content 'London Whiteboard'

    page.find('a.btn.btn-navbar').click if page.has_css?('.btn.btn-navbar')
    page.find('a.posts', text: 'Posts').click
    expect(page).to have_content 'Current Post'
    click_link('Current Post')
    expect(page).to have_content 'London Whiteboard'
    expect(current_page).to match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)

    click_on_preferences(page)
    expect(page).to have_css('input[value="London"]')
    expect(page).to have_css('input[value="[Standup][ENG]"]')
    expect(page).to have_css('input[value="all@pivotallabs.com"]')
    expect(page).to have_css('input[value="Woohoo"]')
    expect(page).to have_css('option[value="Mountain Time (US & Canada)"][selected]')
    expect(page).to have_css('input[value="10:00am"]')

    within '.ip_addresses textarea' do
      expect(page).to have_content('192.168.0.0/24')
      expect(page).to have_content('192.168.1.5')
      expect(page).to have_content('127.0.0.1')
    end
  end

  it "allows you to delete existing standups", js: true do
    click_on_preferences(page)
    click_on 'Delete Standup'
    page.driver.browser.switch_to.alert.accept

    expect(current_url).to match(/http:\/\/127\.0\.0\.1:\d*\/standups$/)
    expect(page).not_to have_content 'London Whiteboard'
  end
end
