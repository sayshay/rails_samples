class Categorization < ActiveRecord::Base
  attr_accessible :category, :categorizable, :categorizable_id, :category_id, :categorizable_type

  validates :categorizable_id, :category_id, :presence => true
  validates_uniqueness_of :category_id, :scope => [:categorizable_id, :categorizable_type]

  belongs_to :category
  belongs_to :categorizable, :polymorphic => true, :touch => true
end
