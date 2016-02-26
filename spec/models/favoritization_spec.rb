require 'spec_helper'

describe 'Favoritization' do

  before(:each) do
    @favoritization = create :favoritization
  end

  subject { @favoritization }

  properties = [:favoritable_id]

  properties.each do |property|
    it { should respond_to property }
  end

  properties.each do |property|
    it { should validate_presence_of property }
  end

  it { should belong_to :user }
  it { should belong_to :favoritable }
end