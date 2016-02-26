class Category < ActiveRecord::Base
  attr_accessible :name, :taggable

  validates :name, :presence => true

  belongs_to :taggable, polymorphic: true

  has_many :categorizations, dependent: :destroy
  has_many :news_sources, :through => :categorizations, :source => :categorizable, :source_type => 'NewsSource'
  has_many :articles, :through => :categorizations, :source => :categorizable, :source_type => 'Article'
  has_many :artists, :through => :categorizations, :source => :categorizable, :source_type => 'Artist'
  has_many :festivals, :through => :categorizations, :source => :categorizable, :source_type => 'Festival'

end
