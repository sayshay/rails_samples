module Taggable
  extend ActiveSupport::Concern

  included do
    has_one :tag, :as => :taggable, :class_name => 'Category', :dependent => :destroy

    after_create :add_tag
  end

  def add_tag
    self.tag = Category.find_or_create_by_name(title)
  end
end
