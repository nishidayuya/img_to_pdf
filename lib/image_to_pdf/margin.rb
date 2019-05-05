require "image_to_pdf"

class ImageToPdf::Margin < Struct.new(:top, :right, :bottom, :left,
                                      keyword_init: true)
end
