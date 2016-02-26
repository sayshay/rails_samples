require 'spec_helper'

describe Article do
  subject(:article) { build :article }

  it_should_behave_like 'image_attachable'
  it_should_behave_like 'categorizable'
  it_should_behave_like 'featurable'

  [:title, :url, :rating, :approved_at, :state, :published_at].each do |property|
    it { should respond_to property }
  end

  it { should validate_presence_of :title }

  context 'featured' do
    before { subject.stub(:featured?) { true } }
    it { should validate_presence_of :featured_image }
  end

  context 'not featured' do
    before { subject.stub(:featured?) { false } }
    it { should_not validate_presence_of :featured_image }
  end

  [:url].each do |property|
    it { should validate_uniqueness_of property }
  end
  it { should ensure_inclusion_of(:rating).in_range(0..10) }

  [:approve, :reject, :enqueue].each do |method|
    it { should respond_to method }
  end

  it { should belong_to :news_source }

end
