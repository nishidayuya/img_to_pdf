require "tempfile"

require "mini_magick"
require "prawn"

require "img_to_pdf"

# An image model
class ImgToPdf::Image
  attr_reader :path

  class << self
    # @param [Pathname] path path to instantiate.
    # @return [ImgToPdf::Image] instance.
    def from_path(path)
      return new(path)
    end
  end

  def initialize(path)
    @dimension_px = nil
    @path = path
  end

  # @return [ImgToPdf::Dimension] image dimension. pixels.
  def dimension_px
    return @dimension_px if @dimension_px

    image_klass = Prawn::Images.const_get(path.extname.upcase.sub(/\A\./, ""))
    image = image_klass.new(path.read)
    @dimension_px = ImgToPdf::Dimension.new(width: image.width, height: image.height)
    return @dimension_px
  end

  # @param [Numeric] x
  # @param [Numeric] y
  # @param [Numeric] width
  # @param [Numeric] height
  # @yieldparam [ImgToPdf::Image] sub_image cropped sub image.
  def crop(x, y, width, height)
    Tempfile.create(["img_to_pdf-image-", path.extname]) do |f|
      f.close
      sub_raw_image_path = Pathname(f.path)

      raw_image = MiniMagick::Image.open(path)
      raw_image.crop("#{width}x#{height}+#{x}+#{y}")
      raw_image.write(sub_raw_image_path)

      sub_image = self.class.from_path(sub_raw_image_path)
      yield(sub_image)
    end
  end
end
