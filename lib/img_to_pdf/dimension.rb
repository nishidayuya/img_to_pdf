require "img_to_pdf"

ImgToPdf::Dimension = Struct.new(:width, :height, keyword_init: true) do
  class << self
    # @param [Array<(Float, Float)>] ary `[width, height]`.
    # @return ImgToPdf::Dimension parsed.
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

  # @return [ImgToPdf::Dimension] transposed dimension.
  def transpose
    return self.class.new(width: height, height: width)
  end

  # @param [:landscape, :portrait] direction
  # @return [ImgToPdf::Dimension] justified dimension.
  def justify_direction(target_direction)
    return direction == target_direction ? dup : transpose
  end

  # points to inches.
  #
  # @return [ImgToPdf::Dimension] inch dimension.
  def pt_to_in
    result = self.class.new(
      width: ImgToPdf::Unit.convert_pt_to_in(width),
      height: ImgToPdf::Unit.convert_pt_to_in(height),
    )
    return result
  end
end
