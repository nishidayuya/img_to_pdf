require "img_to_pdf"

ImgToPdf::Margin = Struct.new(:top, :right, :bottom, :left, keyword_init: true)
