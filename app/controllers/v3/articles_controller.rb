class Api::V3::ArticlesController < Api::V3::BaseController
  PAGE_SIZE = 20

  before_filter :find_user

  def index
    @articles = Article
    .for_scope(params[:scope], current_user)
    .approved
    .for_search_query(params[:query])
    .order('articles.featured DESC, date(articles.published_at) DESC, articles.rating DESC, articles.published_at DESC')
    .offset(params[:offset])
    .limit(PAGE_SIZE)

    respond_with @articles, each_serializer: article_serializer, root: 'articles'
  end

  protected

  def current_user
    @user ||= Guest.new
  end

  private

  def article_serializer
    Api::V3::ArticleSerializer
  end

  def find_user
    unless params[:user_id] == 'guest'
      @user = User.find params[:user_id]
    end
  end

end
