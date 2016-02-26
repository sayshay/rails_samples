class Api::Private::ArticlesController < Api::Private::BaseController
  before_filter :find_or_create_article, except: [:index]

  PAGE_SIZE = 20

  attr_accessor :total_pages

  def index
    @articles = Article
    .for_search_query(params[:query])
    .for_state(params[:state])
    .for_featured(params[:featured])
    .order_for_state(params[:state])
    .page(page)
    .per_page(PAGE_SIZE)

    respond_with @articles,
      each_serializer: article_serializer,
      root: 'articles',
      meta: { total_pages: @articles.total_pages }
  end

  def show
    respond_with_article
  end

  def update
    @article.update_attributes strong_params
    respond_with_article
  end

  private

  def page
    params[:page] ? params[:page] : 1
  end

  def article_serializer
    Api::Private::ArticleSerializer
  end

  def respond_with_article
    respond_with :api, :private, @article, serializer: article_serializer
  end

  def find_or_create_article
    if params.has_key?(:id)
      @article = Article.find params[:id]
    else
      @article = Article.create(strong_params)
    end
  end

  def strong_params
    params.require(:article).permit(:url,
                                    :body, :image,
                                    :rating, :state,
                                    :title, :featured, :featured_image)
  end

end
