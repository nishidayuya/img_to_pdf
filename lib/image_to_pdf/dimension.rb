require "image_to_pdf"

class ImageToPdf::Dimension < Struct.new(:width, :height, keyword_init: true)
  class << self
    # @param [Array<(Float, Float)>] ary `[width, height]`.
    # @return ImageToPdf::Dimension parsed.
    def from_array(ary)
      return new(width: ary[0], height: ary[1])
    end
  end

  # @return [Array<(Float, Float)>] array. `[width, height]`.
  def to_a
    return [width, height]
  end

  # @return [:landscape, :portrait] direction of dimension.
  def direction
    return width > height ? :landscape : :portrait
  end

  # @return [ImageToPdf::Dimension] transposed dimension.
  def transpose
    return self.class.new(width: height, height: width)
  end

  # @param [:landscape, :portrait] direction
  # @return [ImageToPdf::Dimension] justified dimension.
  def justify_direction(target_direction)
    return direction == target_direction ? dup : transpose
  end

  # points to inches.
  #
  # @return [ImageToPdf::Dimension] inch dimension.
  def pt_to_in
    return self.class.new(width: ImageToPdf::Unit.convert_pt_to_in(width),
                          height: ImageToPdf::Unit.convert_pt_to_in(height))
  end
end
