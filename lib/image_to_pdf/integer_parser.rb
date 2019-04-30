require "image_to_pdf"

module ImageToPdf::IntegerParser
  extend self

  def call(s)
    md = /\A\d+\z/.match(s)
    raise ImageToPdf::ParserError, "invalid integer: #{s.inspect}" if !md

    return s.to_i
  end
end
