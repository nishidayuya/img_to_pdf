require "pdf/core/page_geometry"

require "img_to_pdf"

# Parser for paper size
module ImgToPdf::PaperSizeParser
  module_function

  AVAILABLE_DIRECTIONS = %i[landscape portrait]

  # @param [String] s paper size text. "a4-landscape", "b3-portrait", etc.
  # @return [ImgToPdf::Dimension] parsed paper dimension. points.
  def call(s)
    paper_size, direction = *s.split("-")
    direction = direction.downcase.to_sym
    raise ImgToPdf::ParserError, "invalid paper direction: #{s.inspect}" if !AVAILABLE_DIRECTIONS.include?(direction)

    raw_size_pt = PDF::Core::PageGeometry::SIZES[paper_size.upcase]
    raise ImgToPdf::ParserError, "invalid paper size: #{s.inspect}" if !raw_size_pt

    paper_dimension_pt = ImgToPdf::Dimension.from_array(raw_size_pt)
    paper_dimension_pt = paper_dimension_pt.justify_direction(direction)

    return paper_dimension_pt
  end
end
