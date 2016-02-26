require 'spec_helper'

describe NewsSource do
  subject(:news_source) { create :news_source }

  it_should_behave_like 'image_attachable'
  it_should_behave_like 'taggable'

  [:contact_email, :description, :feed_url, :rank, :site_url, :title].each do |property|
    it { should respond_to property }
  end

  [:title, :site_url].each do |property|
    it {
      should validate_presence_of property
      should validate_uniqueness_of property
    }
  end

  it { should have_one :feed }
  it { should have_many :articles }

  describe 'Callbacks' do
    it 'should create a corresponding feed before creation' do
      news_source_attributes = attributes_for :news_source, feed_url: "http://daily-beat.com/feed/"
      news_source = NewsSource.create news_source_attributes
      news_source.feed.persisted?.should be_truthy
    end
  end
end
