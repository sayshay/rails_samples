module Tileable
  extend ActiveSupport::Concern

  included do
    scope :tiled, -> { where('position > ?', -1) }
    scope :tiled_ordered, -> { tiled.order(:position) }

    mount_uploader :rectangular_tile_logo, LogoUploader
    mount_uploader :square_tile_logo, LogoUploader

    attr_accessible :rectangular_tile_logo, :rectangular_tile_logo_cache
    attr_accessible :square_tile_logo, :square_tile_logo_cache
  end

  def menu_type
    "#{self.class.to_s}: #{name}"
  end
end
