require 'spec_helper'

describe 'Categories API', type: :api do

  describe 'GET /api/private/articles' do

    context 'when not authenticated' do
      it do
        get_categories('', auth_header: nil)
        should_respond_not_authenticated
      end
    end

    context 'when authenticated' do
      before do
        @categories = create_list :category, 10
      end

      it  do
        get_categories('category')
        should_respond_ok
        should_respond_with_serialized_categories
        expect(json['categories'].count).to eq(@categories.count)
      end
    end

    private

    def get_categories(query = '', options = default_options)
      get '/api/private/categories.json', { query: query }, auth_header(options)
    end

  end

  ######
  private

  def category_serialized_attributes
    [:id, :title, :type]
  end

  def is_category?(item)
    item_has_keys(item, category_serialized_attributes)
  end

  def should_respond_with_serialized_categories
    json['categories'].each { |item| is_category?(item) }
  end
end
