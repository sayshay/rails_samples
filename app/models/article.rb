class Article < ActiveRecord::Base
  include Categorizable, Featurable

  APPROVED = 'approved'
  PENDING = 'pending'
  REJECTED = 'rejected'

  ALL = 'all'
  MY_NEWS = 'my'
  SAVED = 'saved'


  attr_accessible :url, :body, :image, :rating, :state, :title, :news_source_id, :published_at

  validates :url, :uniqueness => true
  validates :rating, :inclusion => { :in => (0..10) }
  validates :title, :presence => true
  validates :featured_image, :presence => true, :if => :featured?

  mount_uploader :image, PhotoUploader

  after_create :assign_news_source_category

  belongs_to :news_source

  scope :none, where(:id => nil).where("id IS NOT ?", nil)

  def self.for_state(state)
    if state == PENDING
      pending
    elsif state == APPROVED
      approved
    elsif state == REJECTED
      rejected
    else
      scoped
    end
  end

  def self.for_featured(flag)
    if flag == 'true'
      featured
    elsif flag == 'false'
      not_featured
    else
      scoped
    end
  end

  def self.for_search_query(query, include_categories = true)
    return scoped if query.blank?

    if include_categories
      with_categories.where('title LIKE ? OR categories.name LIKE ?', "%#{query}%", "%#{query}%")
    else
      where('title LIKE ?', "%#{query}%")
    end
  end

  def self.with_categories
    includes(:categories)
  end

  def self.order_for_state(state)
    case state
    when APPROVED
      order('articles.approved_at DESC')
    when PENDING
      order('articles.published_at')
    else
      order('articles.created_at DESC')
    end
  end

  def self.pending
    where(state: PENDING)
  end

  def self.approved
    where(state: APPROVED)
  end

  def self.featured
    where(featured: true)
  end

  def self.not_featured
    where(featured: false)
  end

  def self.for_scope(skope, user)
    case skope
    when SAVED
      user.saved_articles.scoped
    when MY_NEWS
      user.tagged_articles.scoped
    else
      scoped
    end
  end

  def assign_news_source_category
    self.categories << self.news_source.tag if self.news_source.tag
  end

  def state=(value)
    if value == APPROVED
      write_attribute :approved_at, DateTime.now if state != APPROVED
    else
      write_attribute :approved_at, nil
    end
    write_attribute(:state, value)
  end

  def image_url
    unless image?
      news_source.image_url
    else
      image.url
    end
  end

  def approve
    self.state = APPROVED
    self.approved_at = DateTime.now
  end

  def reject
    self.state = REJECTED
    self.approved_at = nil
  end

  def enqueue
    self.state = PENDING
    self.approved_at = nil
  end


  def approve!
    approve
    save
  end

  def reject!
    reject
    save
  end

  def enqueue!
    enqueue
    save
  end

end
