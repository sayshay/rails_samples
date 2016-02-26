class Api::V3::NewsController < Api::V3::BaseController

  PAGE_SIZE = 20

  def index
    @articles = Article
    .for_state(Article::APPROVED)
    .for_search_query(params[:query])
    .order_for_state(Article::APPROVED)
    .offset(params[:offset])
    .limit(PAGE_SIZE)

    respond_with @articles, each_serializer: article_serializer, root: 'articles'
  end


private

  def article_serializer
    Api::V3::ArticleSerializer
  end

end
