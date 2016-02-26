class NewsSource < ActiveRecord::Base
  include Taggable, ActiveModel::Validations, ActiveModel::ForbiddenAttributesProtection

  attr_accessible :contact_email, :description, :rank, :image, :site_url, :title, :feed_url
  attr_accessor :feed_url
  mount_uploader :image, NewsSourceImageUploader

  has_one :feed, dependent: :destroy
  has_many :articles, dependent: :destroy

  before_create :generate_feed
  before_update :update_feed

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :contact_email, format: { with: VALID_EMAIL_REGEX }

  validates :title, :site_url, presence: true, uniqueness: true
  validates :feed_url, :site_url, uri: true

  def generate_feed
    self.feed = Feed.create url: feed_url
  end

  def update_feed
    self.feed.update_attributes url: feed_url
  end

end
