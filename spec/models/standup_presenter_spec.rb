require 'spec_helper'
require 'fileutils'

describe StandupPresenter do
  let(:standup) { double(foo: 'bar', closing_message: '', image_urls: '') }
  subject { StandupPresenter.new(standup) }

  it 'delegates methods to standup' do
    expect(subject.foo).to eq('bar')
  end

  context 'when standup object does not have a closing message' do
    it 'picks a closing message' do
      allow(Date).to receive_message_chain(:today, :wday).and_return(4)
      expect(StandupPresenter::STANDUP_CLOSINGS).to include(subject.closing_message)
    end

    it 'should remind us when its Floor Friday' do
      allow(Date).to receive_message_chain(:today, :wday).and_return(5)
      expect(subject.closing_message).to eq("STRETCH! It's Floor Friday!")
    end
  end

  context 'when standup object does have a closing message and image urls are blank' do
    let(:standup) { double(closing_message: 'Yay!') }

    it 'returns the standup closing message' do
      expect(subject.closing_message).to eq('Yay!')
    end
  end

  describe '#closing_image' do
    let(:image_urls) {
      ['http://example.com/bar.png', 'http://example.com/baz.png']
    }
    let!(:standup) { FactoryGirl.create(:standup, image_urls: image_urls.join("\n"), image_days: ['Mon', 'Tue']) }

    context 'when the day is selected' do
      before do
        Timecop.travel(Time.local(2013, 9, 2, 12, 0, 0)) #monday
      end

      after do
        Timecop.return
      end

      context 'when the directory contains files' do
        it 'returns an image url from the list of image urls' do
          expect(image_urls).to include subject.closing_image
        end

        it 'does not return the same image 100 times in a row' do
          images = []
          100.times do
            images << subject.closing_image
          end

          expect(images.uniq.length).to eq(2)
        end
      end
    end

    context 'when the day is not selected' do
      before do
        Timecop.travel(Time.local(2013, 9, 4, 12, 0, 0)) #wednesday
      end

      after do
        Timecop.return
      end

      it 'returns nil' do
        expect(subject.closing_image).to be_nil
      end
    end
  end
end
