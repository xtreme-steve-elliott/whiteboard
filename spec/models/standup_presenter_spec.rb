require 'spec_helper'
require 'fileutils'

describe StandupPresenter do
  let(:standup) { double(foo: 'bar', closing_message: '') }
  subject { StandupPresenter.new(standup) }

  it 'delegates methods to standup' do
    subject.foo.should == 'bar'
  end

  context 'when standup object does not have a closing message' do
    it 'picks a closing message' do
      Date.stub_chain(:today, :wday).and_return(4)
      subject.stub(:rand) { 0 }
      subject.closing_message.should == 'STRETCH!'
    end

    it 'picks a closing message (2)' do
      Date.stub_chain(:today, :wday).and_return(2)
      subject.stub(:rand) { 2 }
      subject.closing_message.should == 'STRETCH!!!!!'
    end

    it 'should remind us when its Floor Friday' do
      Date.stub_chain(:today, :wday).and_return(5)
      subject.closing_message.should == "STRETCH! It's Floor Friday!"
    end
  end

  context 'when standup object does have a closing message and image folder is blank' do
    let(:standup) { double(closing_message: 'Yay!') }

    it 'returns the standup closing message' do
      subject.closing_message.should == 'Yay!'
    end
  end

  describe '#closing_image' do
    context 'when standup image folder is not blank' do
      let!(:standup) { FactoryGirl.create(:standup, image_folder: 'sf') }

      before do
        FakeFS.activate!
      end

      after do
        FakeFS::FileSystem.clear
        FakeFS.deactivate!
      end

      context 'when the directory contains files' do
        before do
          FileUtils.mkdir_p('app/assets/images/sf')
          FileUtils.touch('app/assets/images/sf/foo.jpg')
          FileUtils.touch('app/assets/images/sf/bar.jpg')
        end

        it 'returns an image url from the image folder' do
          ['sf/foo.jpg', 'sf/bar.jpg'].should include subject.closing_image
        end

        it 'does not return the same image 100 times in a row' do
          images = []
          100.times do
            images << subject.closing_image
          end

          images.uniq.length.should == 2
        end
      end

      context 'when there are no files' do
        before do
          FileUtils.mkdir_p('app/assets/images/sf')
        end

        it 'raises an exception' do
          expect{ subject.closing_image}.to raise_error
        end
      end

      context 'when the directory does not exist' do
        it 'raises an exception' do
          expect{ subject.closing_image}.to raise_error
        end
      end
    end
  end


end