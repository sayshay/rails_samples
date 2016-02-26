shared_examples_for 'image_attachable' do
  # Checks that image_attachable has Carrierwave specific methods to handle remote storing
  [:image, :image_url, :image_identifier, :image_cache, :remote_image_url].each do |property|
    it { should respond_to property }
  end
end
