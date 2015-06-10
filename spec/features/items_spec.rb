require 'spec_helper'

describe 'items', :type => :request, js: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco', subject_prefix: '[Standup][SF]', closing_message: 'Woohoo', image_urls: 'http://example.com/bar.png', image_days: ['Mon']) }
  let!(:other_standup) { FactoryGirl.create(:standup, title: 'New York') }
  let(:timezone) { ActiveSupport::TimeZone.new(standup.time_zone_name) }
  let(:date_today) { timezone.now.strftime('%Y-%m-%d') }
  let(:date_tomorrow) { (timezone.now + 1.day).strftime('%Y-%m-%d') }
  let(:date_five_days) { (timezone.now + 5.days).strftime('%Y-%m-%d') }

  before do
    Timecop.travel(Time.local(2013, 9, 2, 12, 0, 0)) #monday
    ENV['ENABLE_WINS'] = 'true'
  end

  after do
    Timecop.return
  end

  context 'new face tests' do
    context 'creation via UI' do
      it 'creates new face entries' do
        login
        visit '/'
        click_link standup.title
        expect {
          find("a[data-kind=\"#{Item::KIND_NEW_FACE}\"] i").click
          fill_in 'item_title', :with => 'Fred Flintstone'
          select other_standup.title, :from => 'item[standup_id]'
          click_button 'Create New Face'

          find("a[data-kind=\"#{Item::KIND_NEW_FACE}\"] i").click
          fill_in 'item_title', :with => 'Johnathon McKenzie'
          fill_in 'item_date', :with => date_today
          select standup.title, from: 'item[standup_id]'
          click_button 'Create New Face'

          find("a[data-kind=\"#{Item::KIND_NEW_FACE}\"] i").click
          fill_in 'item_title', :with => 'Jane Doe'
          fill_in 'item_date', :with => date_five_days
          select standup.title, from: 'item[standup_id]'
          click_button 'Create New Face'
        }.to change {standup.items.count}.by(2).and change {other_standup.items.count}.by(1)
        # TODO: check the values in the new faces themselves
      end
    end

    context 'creation via rails' do
      let!(:fred_flintstone) { FactoryGirl.create(:new_face_item, title: 'Fred Flintstone', date: date_today, standup: other_standup) }
      let!(:johnathon_mckenzie) { FactoryGirl.create(:new_face_item, title: 'Johnathon McKenzie', date: date_today, standup: standup) }
      let!(:jane_doe) { FactoryGirl.create(:new_face_item, title: 'Jane Doe', date: date_five_days, standup: standup) }

      it 'sets up the new faces' do
        login

        visit standup_items_path(standup)
        within '.kind.new_face' do
          expect(page).to have_css('.subheader.today', text: 'Today')
          expect(page).to have_css('.today + .item', text: johnathon_mckenzie.title)
          expect(page).to have_css('.subheader.upcoming', text: 'Upcoming')
          expect(page).to have_css('.upcoming + .item', text: jane_doe.title)
        end

        visit standup_items_path(other_standup)
        within '.kind.new_face' do
          expect(page).to have_css('.subheader.today', text: 'Today')
          expect(page).to have_css('.today + .item', text: fred_flintstone.title)
        end
      end

      it 'sets up the deck' do
        login

        visit presentation_standup_items_path(standup)
        page.execute_script("$.deck('next')")
        within 'section.deck-current' do
          expect(page).to have_css('h2', text: 'New faces')
          expect(page).to have_css('h3.today', text: 'Today')
          expect(page).to have_css('.today + ul li', text: johnathon_mckenzie.title)
          expect(page).to have_css('h3.upcoming', text: 'Upcoming')
          expect(page).to have_css('.upcoming + ul li', text: jane_doe.title)
        end

        visit presentation_standup_items_path(other_standup)
        page.execute_script("$.deck('next')")
        within 'section.deck-current' do
          expect(page).to have_css('h2', text: 'New faces')
          expect(page).to have_css('h3.today', text: 'Today')
          expect(page).to have_css('.today + ul li', text: fred_flintstone.title)
        end
      end
    end
  end

  context 'event tests' do
    context 'creation via UI' do
      it 'creates event entries' do
        login
        visit '/'
        click_link standup.title

        expect {
          find("a[data-kind=\"#{Item::KIND_EVENT}\"] i").click
          fill_in 'item_title', :with => 'Meetup'
          fill_in 'item_date', :with => date_five_days
          select other_standup.title, from: 'item[standup_id]'
          click_button 'Create Item'

          find("a[data-kind=\"#{Item::KIND_EVENT}\"] i").click
          fill_in 'item_title', :with => 'Party'
          fill_in 'item_date', :with => date_five_days
          select standup.title, from: 'item[standup_id]'
          click_button 'Create Item'

          find("a[data-kind=\"#{Item::KIND_EVENT}\"] i").click
          fill_in 'item_title', :with => 'Happy Hour'
          fill_in 'item_date', :with => date_today
          select standup.title, from: 'item[standup_id]'
          click_button 'Create Item'

          find("a[data-kind=\"#{Item::KIND_EVENT}\"] i").click
          fill_in 'item_title', :with => 'Baseball'
          fill_in 'item_date', :with => date_tomorrow
          select standup.title, from: 'item[standup_id]'
          click_button 'Create Item'
        }.to change {standup.items.count}.by(3).and change {other_standup.items.count}.by(1)
      end
    end

    context 'creation via rails' do
      let!(:meetup) { FactoryGirl.create(:event_item, title: 'Meetup', date: date_five_days, standup: other_standup) }
      let!(:party) { FactoryGirl.create(:event_item, title: 'Party', date: date_five_days, standup: standup) }
      let!(:happy_hour) { FactoryGirl.create(:event_item, title: 'Happy Hour', date: date_today, standup: standup) }
      let!(:baseball) { FactoryGirl.create(:event_item, title: 'Baseball', date: date_tomorrow, standup: standup) }

      it 'sets up the events' do
        login

        visit standup_items_path(standup)
        within '.kind.event' do
          expect(page).to have_css('.subheader.today', text: 'Today')
          expect(page).to have_css('.today + .item', text: happy_hour.title)
          expect(page).to have_css('.subheader.tomorrow', text: 'Tomorrow')
          expect(page).to have_css('.tomorrow + .item', text: baseball.title)
          expect(page).to have_css('.subheader.upcoming', text: 'Upcoming')
          expect(page).to have_css('.upcoming + .item', text: party.title)
        end

        visit standup_items_path(other_standup)
        within '.kind.event' do
          expect(page).to have_css('.subheader.upcoming', text: 'Upcoming')
          expect(page).to have_css('.upcoming + .item', text: meetup.title)
        end
      end

      it 'sets up the deck' do
        login

        visit presentation_standup_items_path(standup)
        page.execute_script("$.deck('next')")
        page.execute_script("$.deck('next')")
        page.execute_script("$.deck('next')")
        page.execute_script("$.deck('next')")
        within 'section.deck-current' do
          expect(page).to have_css('h2', text: 'Events')
          expect(page).to have_css('h3.today', text: 'Today')
          expect(page).to have_css('.today + ul li', text: happy_hour.title)
          expect(page).to have_css('h3.tomorrow', text: 'Tomorrow')
          expect(page).to have_css('.tomorrow + ul li', text: baseball.title)
          expect(page).to have_css('h3.upcoming', text: 'Upcoming')
          expect(page).to have_css('.upcoming + ul li', text: party.title)
        end

        visit presentation_standup_items_path(other_standup)
        page.execute_script("$.deck('next')")
        page.execute_script("$.deck('next')")
        page.execute_script("$.deck('next')")
        page.execute_script("$.deck('next')")
        within 'section.deck-current' do
          expect(page).to have_css('h2', text: 'Events')
          expect(page).to have_css('h3.upcoming', text: 'Upcoming')
          expect(page).to have_css('.upcoming + ul li', text: meetup.title)
        end
      end
    end
  end

  # TODO: refactor the rest of this
  it 'setup and deck.js for standup' do
    login
    visit '/'
    click_link(standup.title)

    find('a[data-kind="Interesting"] i').click
    fill_in 'item_title', :with => 'Linux 3.2 out'
    fill_in 'item_author', :with => 'Linus Torvalds'
    fill_in 'item_description', with: 'Check it out: `inline code!` and www.links.com'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    click_button('Interesting')
    fill_in 'item_title', :with => 'Rails 62 is out'
    fill_in 'item_author', :with => 'DHH'
    fill_in 'item_description', with: 'Now with more f-bombs'
    click_button 'Create Item'

    find('a[data-kind="Win"] i').click
    click_button('Win')
    fill_in 'item_title', :with => 'Tracker iOS 7 app'
    fill_in 'item_author', :with => 'Tracker team'
    fill_in 'item_description', with: 'In the app store now! New and shiny!'
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    visit '/'
    click_link(standup.title)

    within '.kind.interesting' do
      expect(page).to have_css('.item', text: 'Linus Torvalds')
      first('a[data-toggle]').click
      expect(page).to have_selector('.in')
      expect(page).to have_selector('code', text: 'inline code!')
      expect(page).to have_link('www.links.com')
    end

    within '.kind.win' do
      expect(page).to have_css('.item', text: 'Tracker iOS 7 app')
    end

    visit presentation_standup_items_path(standup)

    within 'section.deck-current' do
      expect(page).to have_content 'Standup'
      expect(page).to have_css('.countdown')
    end
    page.execute_script("$.deck('next')")
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content 'Helps'
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).to have_content 'Interestings'
      expect(page).to have_content('Linux 3.2 out')
      expect(page).to have_content('Linus Torvalds')
      expect(page).to have_content('Rails 62 is out')
      expect(page).not_to have_selector('.in')
      first('a[data-toggle]').click
      expect(page).to have_selector('.in')
      expect(page).to have_content('Check it out:')
      expect(page).to have_link('www.links.com')
      expect(page).to have_selector('code', text: 'inline code!')
    end
    page.execute_script("$.deck('next')")
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content 'Wins'
    expect(page).to have_css('section.deck-current', text: 'Tracker iOS 7 app')
    expect(find('section.deck-current')).not_to have_content 'Happy Hour'
    expect(find('section.deck-current')).not_to have_content 'Baseball'
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).not_to have_content 'Wins'
      expect(page).to have_content 'Woohoo'
      expect(page).to have_css('img[src="http://example.com/bar.png"]')
    end

    all('.exit-presentation').first.click

    expect(current_path).to eq(standup_items_path(standup))
  end

  it 'does not let you create wins if the feature flag is off' do
    ENV['ENABLE_WINS'] = 'false'

    login
    visit '/'
    click_link(standup.title)

    expect(page).not_to have_css('a[data-kind="Win"] i')
  end

  it 'hides wins if there are none' do
    login
    visit presentation_standup_items_path(standup)

    within 'section.deck-current' do
      expect(page).to have_content 'Standup'
      expect(page).to have_css('.countdown')
    end
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content 'New faces'
    page.execute_script("$.deck('next')")
    expect(find('section.deck-current')).to have_content 'Helps'
    page.execute_script("$.deck('next')")
    expect(find('section.deck-current')).to have_content 'Interestings'
    page.execute_script("$.deck('next')")
    expect(find('section.deck-current')).to have_content 'Events'
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).not_to have_content 'Wins'
      expect(page).to have_content 'Woohoo'
    end
  end
end
