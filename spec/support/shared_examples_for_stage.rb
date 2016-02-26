shared_examples_for 'stage' do
  [:party_id, :name, :party, :performances, :artists].each do |property|
    it { should respond_to property }
  end
end