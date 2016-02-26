class Api::Private::CategorizationsController < Api::Private::BaseController
  before_filter :find_or_create_categorization

  def create
    respond_with_categorization
  end

  def destroy
    @categorization.destroy
    respond_with_categorization
  end

private

  def find_or_create_categorization
    @categorization = params.has_key?(:id) ? Categorization.find(params[:id]) : Categorization.create(strong_params)
  end

  def categorization_serializer
    Api::Private::CategorizationSerializer
  end

  def respond_with_categorization
    respond_with :api, :private, @categorization, serializer: categorization_serializer
  end

  def strong_params
    params.require(:categorization).permit(:categorizable_id, :category_id, :categorizable_type)
  end

end
