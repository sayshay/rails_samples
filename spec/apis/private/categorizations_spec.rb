require 'spec_helper'

describe 'Categorizations API', type: :api do

  describe 'POST /api/private/categorizations' do
    let(:categorization_atrributes) { build(:categorization_for_artist).attributes }

    context 'when not authenticated' do
      it do
        create_categorization(categorization_atrributes, auth_header: nil)
        should_respond_not_authenticated
      end
    end

    context 'when invalid data sent' do
      it do
        categorization_atrributes[:categorizable_type] = nil
        categorization_atrributes[:categorizable_id] = nil
        categorization_atrributes[:category_id] = nil
        create_categorization(categorization_atrributes)
        should_respond_with_errors_for [:category_id, :categorizable_id]
      end
    end

    context 'when valid data sent' do
      it do
        create_categorization(categorization_atrributes)
        should_respond_created
        should_respond_with_serialized_categorization
      end
    end

    private

    def create_categorization(attributes, options = default_options)
      post '/api/private/categorizations.json', { categorization: attributes }, auth_header(options)
    end
  end


  describe 'DELETE /api/private/categorizations/:id' do
    subject(:categorization) { create :categorization_for_artist }

    context 'when not authenticated' do
      it do
        delete_categorization(categorization.id, auth_header: nil)
        should_respond_not_authenticated
      end
    end

    context 'when categorization not found' do
      let(:unknown_id) { -1 }
      it do
        delete_categorization(unknown_id)
        should_respond_not_found
      end
    end

    context 'when categorization exists' do
      it do
        delete_categorization(categorization.id)
        should_respond_with_no_content
        expect { categorization.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    private

    def delete_categorization(id, options = default_options)
      delete "/api/private/categorizations/#{id}.json", {}, auth_header(options)
    end
  end


  #####
  private

  def categorization_serialized_attributes
    [:id, :category_id, :categorizable_id]
  end

  def is_categorization?(item)
    item_has_keys(item, categorization_serialized_attributes)
  end

  def should_respond_with_serialized_categorization(id = nil)
    is_categorization?(json['categorization'])
    expect(json['categorization']["id"]).to eq(id) if id
  end

  def should_respond_with_serialized_categorizations
    json['categorizations'].each { |item| is_categorization?(item) }
  end
end
