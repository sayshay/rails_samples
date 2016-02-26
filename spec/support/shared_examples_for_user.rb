shared_examples_for 'user' do
  [:email,
    :first_name,
    :last_name,
    :udid,
    :apns_token,
    :gcm_token,
    :photo,
    :facebook_token,
    :facebook_url,
    :facebook_id,
    :twitter_url,
    :instagram_url,
    :soundcloud_url,
    :categories,
    :saved_articles,
    :tagged_articles,
    :favoritizations,
    :favoritizarion_id_for
  ].each do |property|
    it { should respond_to property }
  end

end
