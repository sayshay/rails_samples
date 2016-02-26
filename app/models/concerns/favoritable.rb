module Favoritable
  extend ActiveSupport::Concern

  included do
    attr_accessor :favorite
    alias_method :favorite?, :favorite

    has_many :favoritizations, :as => :favoritable, :uniq => true

    def favorite
      @favorite || false
    end
  end
end