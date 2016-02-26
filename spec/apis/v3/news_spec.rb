require 'spec_helper'


describe 'News API', type: :api do

  describe 'GET /api/v3/news' do

    let(:page_size) { Api::V3::ArticlesController::PAGE_SIZE }

    context 'guest user' do

      before do
        create_list :article, 10
        @articles = create_list :article, 30, state: Article::APPROVED

        @distintc_article1 = create :article, title: 'Disctinct Article 1', state: Article::APPROVED
        @distintc_article2 = create :article, title: 'Disctinct Article 2', state: Article::APPROVED
        @distintc_article3 = create :article, title: 'Disctinct Article 3'

        @distintc_approved_articles = [@distintc_article1, @distintc_article2]

        @articles << @distintc_article1
        @articles << @distintc_article2
      end

      it 'returns all approved articles' do
        get_articles
        should_respond_ok
        should_respond_with_serialized_approved_articles
        expect(json['articles'].count).to eq(page_size)

        get_articles(offset: page_size)
        should_respond_ok
        refresh_json
        should_respond_with_serialized_approved_articles

        expect(json['articles'].count).to eq(@articles.size - page_size)
      end

      it 'returns searched approved articles' do
        get_articles(query: 'Disctinct Article')
        should_respond_ok
        refresh_json
        should_respond_with_serialized_approved_articles
        expect(json['articles'].count).to eq(@distintc_approved_articles.count)
      end

      it 'returns empty list for my articles' do
        get_articles(scope: Article::MY_NEWS)
        should_respond_ok
        expect(json['articles'].count).to eq(0)
      end

      it 'returns empty list for saved articles' do
        get_articles(scope: Article::SAVED)
        should_respond_ok
        expect(json['articles'].count).to eq(0)
      end
    end

    context 'signed in user' do
      before do
        @pending_articles = create_list :article, 10
        @approved_articles = create_list :article, 30, state: Article::APPROVED
        @user = create :user_with_profile
        @category1 = create :category
        @category2 = create :category

        @approved_articles[0..4].each do |a|
          a.categories << @category1
        end
        @approved_articles[5..10].each do |a|
          a.categories << @category2
        end

        # gets excluded from the results because is not approved
        @user.saved_articles << @pending_articles[0]
        @user.saved_articles << @approved_articles[0]
        @user.saved_articles << @approved_articles[5]
        # gets excluded from the first batch fetch because gets into second batch due to sorting
        @user.saved_articles << @approved_articles[15]

        @user.categories << @category2
      end

      it 'returns all approved articles' do
        get_articles(user: @user.id)
        should_respond_ok

        should_respond_with_serialized_approved_articles
        should_respond_with_serialized_categories

        expect(json['articles'].count).to eq(page_size)
        expect(json['categories'].count).to eq(2)
      end

      it 'returns my articles' do
        get_articles(user: @user.id, scope: Article::MY_NEWS)
        should_respond_ok

        should_respond_with_serialized_approved_articles
        should_respond_with_serialized_categories

        expect(json['articles'].count).to eq(6)
        expect(json['categories'].count).to eq(1)
      end

      it 'returns saved articles' do
        get_articles(user: @user.id, scope: Article::SAVED)
        should_respond_ok

        should_respond_with_serialized_approved_articles
        should_respond_with_serialized_categories

        expect(json['articles'].count).to eq(3)
      end

    end

    private

    def get_articles(parameters = {}, options = guest_options)
      user = parameters.fetch(:user, 'guest')
      scope = parameters.fetch(:scope, Article::ALL)
      query = parameters.fetch(:query, '')
      offset = parameters.fetch(:offset, '')

      get "/api/v3/users/#{user}/articles.json",
      {
        scope: scope,
        offset: offset,
        query: query
      },
        auth_header(options)
    end
  end


  #####
  private

  def article_serialized_attributes
    [:id, :title, :body, :image_url, :news_source_id, :url,
      :rating, :approved_at, :state, :published_at, :created_at, :updated_at,
    :favoritization_id, :news_source_name]
  end

  def favoritization_serialized_attributes
    [:id, :favoritable_id, :favoritable_type, :user_id]
  end

  def category_serialized_attributes
    [:id, :name, :favoritization_id]
  end

  def is_approved_article?(item)
    item_has_keys(item, article_serialized_attributes)
    expect(item['state']).to eq(Article::APPROVED)
  end

  def is_favoritization?(item)
    item_has_keys(item, favoritization_serialized_attributes)
  end

  def is_category?(item)
    item_has_keys(item, category_serialized_attributes)
  end

  #def should_respond_with_serialized_approved_article(id = nil)
  #  is_article?(json['article'])
  #  json['article']['state'].to eq Article::APPROVED
  #  expect(json['article']["id"]).to eq(id) if id
  #end

  def should_respond_with_serialized_approved_articles
    json['articles'].each { |item| is_approved_article?(item) }
  end

  def should_respond_with_serialized_favoritizations
    json['articles'].each do |a|
      if a['favoritization']
        is_favoritization?(a['favoritization'])
      end
    end
  end

  def should_respond_with_serialized_categories
    json['categories'].each { |item| is_category? item }
  end
end
