require "tmpdir"

require "mini_magick"
require "prawn"

require "image_to_pdf"

module ImageToPdf::Cli
  extend self

  def run(argv)
    option = ImageToPdf::CliOption.from_argv(argv)
    page_dimension_pt = ImageToPdf::PaperSizeParser.(option.paper_size_text)

    canvas_dimension_pt = ImageToPdf::Dimension.new(
      width: ((page_dimension_pt.width - option.margin_pt.left - option.margin_pt.right) *
              option.n_horizontal_pages),
      height: ((page_dimension_pt.height - option.margin_pt.top - option.margin_pt.bottom) *
               option.n_vertical_pages),
    )
    canvas_dimension_in = canvas_dimension_pt.pt_to_in

    image = ImageToPdf::Image.from_path(option.input_path)
    dpi_from_width = image.dimension_px.width / canvas_dimension_in.width
    dpi_from_height = image.dimension_px.height / canvas_dimension_in.height
    canvas_dpi = [dpi_from_width, dpi_from_height].max
    canvas_scale = 72 / canvas_dpi

    tmp_image_dimension_px = ImageToPdf::Dimension.new(
      width: image.dimension_px.width / option.n_horizontal_pages,
      height: image.dimension_px.height / option.n_vertical_pages,
    )

    pdf = Prawn::Document.new(
      page_size: page_dimension_pt.to_a,
      margin: option.margin_pt.to_a,
      skip_page_creation: true,
      info: {
        Creator: "image_to_pdf version #{ImageToPdf::VERSION}",
      }
    )
    option.n_vertical_pages.times do |i_y|
      option.n_horizontal_pages.times do |i_x|
        image.crop(tmp_image_dimension_px.width * i_x,
                   tmp_image_dimension_px.height * i_y,
                   tmp_image_dimension_px.width,
                   tmp_image_dimension_px.height) do |sub_image|
          pdf.start_new_page
          pdf.image(
            sub_image.path,
            scale: canvas_scale,
            at: [0, canvas_dimension_pt.height / option.n_vertical_pages],
          )
        end
      end
    end
    pdf.render_file(option.output_path)
  rescue ImageToPdf::Error => e
    raise if option.debug
    STDERR.puts("#{e.class.name}: #{e.message}")
    exit(1)
  end
end
