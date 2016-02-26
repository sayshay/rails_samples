shared_examples_for 'categorizable' do
  it { should have_many(:categorizations) }
  it { should have_many(:categories).through(:categorizations) }
  it { should have_many(:news_source_categories).through(:categorizations) }
  it { should have_many(:artist_categories).through(:categorizations) }
  it { should have_many(:festival_categories).through(:categorizations) }
end
