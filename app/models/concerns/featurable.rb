module Featurable
  extend ActiveSupport::Concern

  included do
    attr_accessible :featured, :featured_image
    alias_attribute :featured?, :featured

    mount_uploader :featured_image, PhotoUploader
  end
end
