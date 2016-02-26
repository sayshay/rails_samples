require 'spec_helper'

describe 'Articles API', type: :api do

  describe 'GET /api/private/articles' do

    context 'when not authenticated' do
      it {
        get_all_articles(0, auth_header: nil)
        should_respond_not_authenticated
      }
    end

    context 'when authenticated' do
      let(:page_size) { Api::Private::ArticlesController::PAGE_SIZE }
      before do
        @distintc_article1 = create :article, title: 'Disctinct Article 1'
        @distintc_article2 = create :article, title: 'Disctinct Article 2'

        @pending_articles = create_list :article, 10, state: Article::PENDING
        @approved_articles = create_list :article, 10, state: Article::APPROVED
        @rejected_articles = create_list :article, 10, state: Article::REJECTED
        @distintc_articles = [@distintc_article1, @distintc_article2]
        @featured_articles = create_list :featured_article, 10
        @not_featured_articles = create_list :article, 10, featured: false
        @pending_articles += @distintc_articles
        @pending_articles += @featured_articles
        @pending_articles += @not_featured_articles

        @articles = @pending_articles + @approved_articles + @rejected_articles
      end

      it 'returns all articles' do
        get_all_articles
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(page_size)

        get_all_articles(3)
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(@articles.size - 2 * page_size)
      end

      it 'returns pending articles' do
        get_pending_articles
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(page_size_or_less(@pending_articles.count, page_size))
        json['articles'].all? do |article|
          article['state'] == Article::PENDING
        end.should be_truthy
      end

      it 'returns approved articles' do
        get_approved_articles
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(page_size_or_less(@approved_articles.count, page_size))
        json['articles'].all? do |article|
          article['state'] == Article::APPROVED
        end.should be_truthy
      end

      it 'returns searched articles' do
        get_articles_with_search('Disctinct Article')
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(@distintc_articles.count)
        json['articles'].any? do |article|
          article['title'] == @distintc_article1.title
        end.should be_truthy
      end

      it 'returns featured articles' do
        get_featured_articles
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(page_size_or_less(@featured_articles.count, page_size))        
        json['articles'].all? do |article|
          article['featured'] == true
        end.should be_truthy

      end

      it 'returns not featured articles' do
        get_not_featured_articles
        should_respond_ok
        refresh_json
        should_respond_with_serialized_articles
        expect(json['articles'].count).to eq(page_size_or_less(@articles.count - @featured_articles.count, page_size))
        json['articles'].all? do |article|
          article['featured'] == false
        end.should be_truthy
      end
    end

    private

    def page_size_or_less(count, page_size)
      count > page_size ? page_size : count
    end

    def get_pending_articles(options = default_options)
      get '/api/private/articles.json', { state: Article::PENDING }, auth_header(options)
    end

    def get_all_articles(page = 1, options = default_options)
      get '/api/private/articles.json', { page: page }, auth_header(options)
    end

    def get_approved_articles(options = default_options)
      get '/api/private/articles.json', { state: Article::APPROVED }, auth_header(options)
    end

    def get_articles_with_search(search_criteria, options = default_options)
      get '/api/private/articles.json', { query: search_criteria }, auth_header(options)
    end

    def get_featured_articles(options = default_options)
      get '/api/private/articles.json', { featured: true }, auth_header(options)
    end

    def get_not_featured_articles(options = default_options)
      get '/api/private/articles.json', { featured: false }, auth_header(options)
    end

  end

  describe 'GET /api/private/articles/:id' do
    subject(:article) { create :article }

    context 'when not authenticated' do
      it do
        get_article(article.id, auth_header: nil)
        should_respond_not_authenticated
      end
    end

    context 'when article not found' do
      let(:unknown_id) { -1 }
      it do
        get_article(unknown_id)
        should_respond_not_found
      end
    end

    context 'when article exists' do
      it do
        get_article(article.id)
        should_respond_ok
        should_respond_with_serialized_article(article.id)
      end
    end

    private

    def get_article(id, options = default_options)
      get "/api/private/articles/#{id}.json", { }, auth_header(options)
    end

  end

  describe 'PUT /api/private/articles/:id' do
    subject(:article) { create :article }

    before :each do
      @new_article_attributes = attributes_for :article
    end

    context 'when not authenticated' do
      it do
        update_article(article.id, @new_article_attributes, auth_header: nil)
        should_respond_not_authenticated
      end
    end

    context 'when article not found' do
      let(:unknown_id) { -1 }
      it do
        update_article(unknown_id, @new_article_attributes)
        should_respond_not_found
      end
    end

    context 'when invalid data sent' do
      it do
        @new_article_attributes['title'] = nil
        update_article(article.id, @new_article_attributes)
        should_respond_with_errors_for [:title]
      end
    end

    context 'when valid data sent' do
      it do
        update_article(article.id, @new_article_attributes)
        should_respond_with_no_content
        expect(article.reload).to eq(article)
      end
    end

    private

    def update_article(id, article_attributes, options = default_options)
      put "/api/private/articles/#{id}.json", { article: article_attributes }, auth_header(options)
    end

  end

  ######
  private

  def article_serialized_attributes
    [:id, :title, :body, :image_url, :news_source_id, :url,
      :rating, :approved_at, :state, :published_at, :created_at, :updated_at]
  end

  def is_article?(item)
    item_has_keys(item, article_serialized_attributes)
  end

  def should_respond_with_serialized_article(id = nil)
    is_article?(json['article'])
    expect(json['article']["id"]).to eq(id) if id
  end

  def should_respond_with_serialized_articles
    json['articles'].each { |item| is_article?(item) }
  end

end
