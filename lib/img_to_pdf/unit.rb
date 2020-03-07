require "img_to_pdf"

# Unit conversion module
module ImgToPdf::Unit
  extend self

  # @param [Float] mm source length. millimeters.
  # @return [Float] destination length. points.
  def convert_mm_to_pt(mm)
    return mm / 25.4 * 72
  end

  # @param [Float] pt source length. points.
  # @return [Float] destination length. inches.
  def convert_pt_to_in(pt)
    return pt / 72
  end
end
