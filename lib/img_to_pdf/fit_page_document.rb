require "prawn"

require "img_to_pdf"

# A document model
class ImgToPdf::FitPageDocument
  # @param [ImgToPdf::Dimension] page_dimension_pt page size. points.
  # @param [ImgToPdf::Margin] margin_pt margin size. points.
  # @param [ImgToPdf::Image] image source image.
  # @param [Integer] n_horizontal_pages number of horizontal pages.
  # @param [Integer] n_vertical_pages number of vertical pages.
  # @return [ImgToPdf::FitPageDocument] document to render PDF.
  def self.create(page_dimension_pt:, margin_pt:, image:,
                  n_horizontal_pages: 1, n_vertical_pages: 1)
    result = new(page_dimension_pt: page_dimension_pt, margin_pt: margin_pt,
                 n_horizontal_pages: n_horizontal_pages,
                 n_vertical_pages: n_vertical_pages,
                 image: image)
    result.draw
    return result
  end

  def initialize(page_dimension_pt:, margin_pt:, image:,
                 n_horizontal_pages:, n_vertical_pages:)
    @page_dimension_pt = page_dimension_pt
    @margin_pt = margin_pt
    @image = image
    @n_horizontal_pages = n_horizontal_pages
    @n_vertical_pages = n_vertical_pages

    @pdf = Prawn::Document.new(
      page_size: @page_dimension_pt.to_a,
      margin: @margin_pt.to_a,
      skip_page_creation: true,
      info: {
        Creator: "img_to_pdf version #{ImgToPdf::VERSION}",
      },
    )
  end

  def draw
    canvas_dimension_pt = determine_canvas_dimension_pt
    canvas_scale = determine_canvas_scale(canvas_dimension_pt)
    sub_image_dimension_px = ImgToPdf::Dimension.new(
      width: @image.dimension_px.width / @n_horizontal_pages,
      height: @image.dimension_px.height / @n_vertical_pages,
    )
    each_sub_image(sub_image_dimension_px) do |sub_image|
      @pdf.start_new_page
      @pdf.image(
        sub_image.path,
        scale: canvas_scale,
        at: [0, canvas_dimension_pt.height / @n_vertical_pages],
      )
    end
  end

  # @param [Pathname] output_path path to PDF output.
  def render_file(output_path)
    @pdf.render_file(output_path)
  end

  private

  def determine_canvas_dimension_pt
    w = (@page_dimension_pt.width - @margin_pt.left - @margin_pt.right) *
        @n_horizontal_pages
    h = (@page_dimension_pt.height - @margin_pt.top - @margin_pt.bottom) *
        @n_vertical_pages
    return ImgToPdf::Dimension.new(width: w, height: h)
  end

  def determine_canvas_scale(canvas_dimension_pt)
    canvas_dimension_in = canvas_dimension_pt.pt_to_in
    dpi_from_width = @image.dimension_px.width / canvas_dimension_in.width
    dpi_from_height = @image.dimension_px.height / canvas_dimension_in.height
    canvas_dpi = [dpi_from_width, dpi_from_height].max
    return 72 / canvas_dpi
  end

  def each_sub_image(sub_image_dimension_px)
    @n_vertical_pages.times do |i_y|
      @n_horizontal_pages.times do |i_x|
        @image.crop(sub_image_dimension_px.width * i_x,
                    sub_image_dimension_px.height * i_y,
                    sub_image_dimension_px.width,
                    sub_image_dimension_px.height) do |sub_image|
          yield(sub_image)
        end
      end
    end
  end
end
