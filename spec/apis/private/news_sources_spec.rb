require 'spec_helper'

describe 'News Sources API', type: :api do

  describe 'POST /api/private/news_sources' do
    let(:news_source_data) { attributes_for :news_source, feed_url: 'http://daily-beat.com/feed/' }

    context 'when not authenticated' do
      it {
        create_news_source(news_source_data, auth_header: nil)
        should_respond_not_authenticated
      }
    end

    context 'when invalid data sent' do
      it {
        news_source_data[:title] = nil
        news_source_data[:feed_url] = 'invalid url'
        news_source_data[:site_url] = 'https:/invalid url'
        news_source_data[:contact_email] = 'invalid@email'
        create_news_source(news_source_data)
        should_respond_with_errors_for [:title, :feed_url, :site_url, :contact_email]
      }
    end

    context 'when valid news source data sent' do
      it {
        create_news_source(news_source_data)
        should_respond_created
        should_respond_with_serialized_news_source
      }
    end

    private

    def create_news_source(data, options = default_options)
      post '/api/private/news_sources.json', { news_source: data }, auth_header(options)
    end

  end

  describe 'GET /api/private/news_sources' do

    context 'when not authenticated' do
      it {
        get_news_sources(auth_header: nil)
        should_respond_not_authenticated
      }
    end

    context 'when authenticated' do
      before {
        @news_sources = create_list :news_source, 10
      }

      it {
        get_news_sources
        should_respond_ok
        should_respond_with_serialized_news_sources
        expect(json['news_sources'].count).to eq(@news_sources.count)
      }
    end

    private

    def get_news_sources(options = default_options)
      get '/api/private/news_sources.json', {}, auth_header(options)
    end

  end

  describe 'GET /api/private/news_sources/:id' do
    subject(:news_source) { create :news_source }

    context 'when not authenticated' do
      it {
        get_news_source(news_source.id, auth_header: nil)
        should_respond_not_authenticated
      }
    end

    context 'when news source not found' do
      let(:unknown_id) { -1 }
      it {
        get_news_source(unknown_id)
        should_respond_not_found
      }
    end

    context 'when news source exists' do
      it {
        get_news_source(news_source.id)
        should_respond_ok
        should_respond_with_serialized_news_source(news_source.id)
      }
    end

    private

    def get_news_source(id, options = default_options)
      get "/api/private/news_sources/#{id}.json", { }, auth_header(options)
    end

  end

  describe 'PUT /api/private/news_sources/:id' do
    subject(:news_source) { create :news_source }

    before :each do
      news_source.title = 'changed title'
      @news_source_attributes = attributes_for :news_source
    end

    context 'when not authenticated' do
      it {
        update_news_source(news_source.id, @news_source_attributes, auth_header: nil)
        should_respond_not_authenticated
      }
    end

    context 'when news source not found' do
      let(:unknown_id) { -1 }
      it {
        update_news_source(unknown_id, @news_source_attributes)
        should_respond_not_found
      }
    end

    context 'when invalid data sent' do
      it {
        news_source_attributes = {}
        news_source_attributes[:title] = nil
        news_source_attributes[:feed_url] = 'invalid url'
        news_source_attributes[:site_url] = 'invalid url'
        news_source_attributes[:contact_email] = 'invalid@email'

        update_news_source(news_source.id, news_source_attributes)
        should_respond_with_errors_for [:title, :feed_url, :site_url, :contact_email]
      }
    end

    context 'when valid data sent' do
      it {
        update_news_source(news_source.id, @news_source_attributes)
        should_respond_with_no_content

        news_source.reload

        expect(news_source.title).to eq(@news_source_attributes[:title])
        expect(news_source.feed.url).to eq(@news_source_attributes[:feed_url])
        expect(news_source.site_url).to eq(@news_source_attributes[:site_url])
        expect(news_source.contact_email).to eq(@news_source_attributes[:contact_email])
      }
    end

    private

    def update_news_source(id, news_source_attributes, options = default_options)
      put "/api/private/news_sources/#{id}.json", { news_source: news_source_attributes }, auth_header(options)
    end

  end

  describe 'DELETE /api/private/news_sources/:id' do
    subject(:news_source) { create :news_source }

    context 'when not authenticated' do
      it {
        delete_news_source(news_source.id, auth_header: nil)
        should_respond_not_authenticated
      }
    end

    context 'when news source not found' do
      let(:unknown_id) { -1 }
      it {
        delete_news_source(unknown_id)
        should_respond_not_found
      }
    end

    context 'when news source exists' do
      it {
        delete_news_source(news_source.id)
        should_respond_with_no_content
        expect { news_source.reload }.to raise_error(ActiveRecord::RecordNotFound)
      }
    end

    private

    def delete_news_source(id, options = default_options)
      delete "/api/private/news_sources/#{id}.json", { }, auth_header(options)
    end

  end

private

  def news_source_serialized_attributes
    [:id, :contact_email, :description, :feed_url, :rank, :image_url, :site_url, :title]
  end

  def is_news_source?(item)
    item_has_keys(item, news_source_serialized_attributes)
  end

  def should_respond_with_serialized_news_source(id = nil)
    is_news_source?(json['news_source'])
    expect(json['news_source']["id"]).to eq(id) if id
  end

  def should_respond_with_serialized_news_sources
    json['news_sources'].each { |item| is_news_source?(item) }
  end

end


