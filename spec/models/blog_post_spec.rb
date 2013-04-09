require 'spec_helper'

describe BlogPost do
  describe '#post_hash' do
    before do
      subject.title = 'title'
      subject.body = 'description'
      subject.keywords = 'keywords'
      subject.categories = 'categories'
    end

    it 'returns a properly formed hash' do
      subject.post_hash.should == {
        'title' => 'title',
        'description' => 'description',
        'mt_keywords' => 'keywords',
        'categories' => 'categories'
      }
    end
  end

  describe '#keywords' do
    it 'returns keywords if set' do
      subject.keywords = 'keywords'
      subject.keywords.should == 'keywords'
    end

    it 'returns [] if no keywords were set' do
      subject.keywords.should == []
    end
  end

  describe '#categories' do
    it 'returns categories if set' do
      subject.categories = 'categories'
      subject.categories.should == 'categories'
    end
    
    it 'returns ["standup"] if no categories were set' do
      subject.categories.should == ['standup']
    end
  end
end
