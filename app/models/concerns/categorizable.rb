module Categorizable
  extend ActiveSupport::Concern

  included do
    has_many :categorizations, :as => :categorizable, :dependent => :destroy
    has_many :categories, :through => :categorizations

    has_many :news_source_categories,
      :through => :categorizations,
      :source => :category,
      :conditions => { :taggable_type => 'NewsSource' }

    has_many :artist_categories, :through => :categorizations,
      :source => :category,
      :conditions => { :taggable_type => 'Artist' }

    has_many :festival_categories, :through => :categorizations,
      :source => :category,
      :conditions => { :taggable_type => 'Party' }

  end

end
