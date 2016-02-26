shared_examples_for 'tileable' do
  [:position, :rectangular_tile_logo, :square_tile_logo].each do |property|
    it { should respond_to property }
  end
end
