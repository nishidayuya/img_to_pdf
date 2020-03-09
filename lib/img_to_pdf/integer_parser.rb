require "img_to_pdf"

# Parser for integer string
module ImgToPdf::IntegerParser
  module_function

  def call(s)
    md = /\A\d+\z/.match(s)
    raise ImgToPdf::ParserError, "invalid integer: #{s.inspect}" if !md

    return s.to_i
  end
end
