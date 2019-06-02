require "img_to_pdf"

class ImgToPdf::Margin < Struct.new(:top, :right, :bottom, :left,
                                      keyword_init: true)
end
