require 'spec_helper'

describe Category do
  subject(:category) { build :category }

  [:name].each do |property|
    it { should respond_to property }
  end

  it { should validate_presence_of :name }

  it { should have_many :categorizations }
  it { should have_many(:news_sources).through(:categorizations) }
  it { should have_many(:articles).through(:categorizations) }
  it { should have_many(:artists).through(:categorizations) }
  it { should have_many(:festivals).through(:categorizations) }
end
