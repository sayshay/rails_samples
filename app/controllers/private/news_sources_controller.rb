class Api::Private::NewsSourcesController < Api::Private::BaseController
  before_filter :find_or_create_news_source, except: [:index]

  def index
    respond_with NewsSource.all, each_serializer: news_source_serializer, root: "news_sources"
  end

  def create
    respond_with_news_source
  end

  def show
    respond_with_news_source
  end

  def update
    @news_source.update_attributes(strong_params)
    respond_with_news_source
  end

  def destroy
    @news_source.destroy
    respond_with_news_source
  end

private

  def find_or_create_news_source
    if params.has_key?(:id)
      @news_source = NewsSource.find(params[:id])
    else
      @news_source = NewsSource.create(strong_params)
    end
  end

  def news_source_serializer
    Api::Private::NewsSourceSerializer
  end

  def respond_with_news_source
    respond_with :api, :private, @news_source, serializer: news_source_serializer
  end

  def strong_params
    params.require(:news_source).permit(:contact_email, :description, :rank, :image, :site_url, :title, :feed_url)
  end

end
