class Api::Private::CategoriesController < Api::Private::BaseController
  def index
    categories = Category.where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%").take(100)
    respond_with categories, each_serializer: category_serializer, root: 'categories'
  end

  private

  def category_serializer
    Api::Private::CategorySerializer
  end
end
