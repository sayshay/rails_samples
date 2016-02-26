shared_examples_for 'featurable' do
  [:featured, :featured?, :featured_image].each do |property|
    it { should respond_to property }
  end
end
