require "pathname"
require "tmpdir"

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

    image_dimension_px = parse_image_dimension(option.input_path)
    dpi_from_width = image_dimension_px.width / canvas_dimension_in.width
    dpi_from_height = image_dimension_px.height / canvas_dimension_in.height
    canvas_dpi = [dpi_from_width, dpi_from_height].max
    canvas_scale = 72 / canvas_dpi

    tmp_path = Pathname(Dir.mktmpdir)
    tmp_image_dimension_px = ImageToPdf::Dimension.new(
      width: image_dimension_px.width / option.n_horizontal_pages,
      height: image_dimension_px.height / option.n_vertical_pages,
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
        tmp_image_path = tmp_path / "#{i_x}-#{i_y}"

        image = MiniMagick::Image.open(option.input_path)
        image.crop("#{tmp_image_dimension_px.width}x#{tmp_image_dimension_px.height}+#{tmp_image_dimension_px.width * i_x}+#{tmp_image_dimension_px.height * i_y}")
        image.write(tmp_image_path)

        pdf.start_new_page
        pdf.image(
          tmp_image_path,
          scale: canvas_scale,
          at: [0, canvas_dimension_pt.height / option.n_vertical_pages],
        )
      end
    end
    pdf.render_file(option.output_path)
  rescue ImageToPdf::Error => e
    raise if option.debug
    STDERR.puts("#{e.class.name}: #{e.message}")
    exit(1)
  ensure
    tmp_path&.rmtree
  end

  private

  # @param [Pathname] path path to image file.
  # @return [ImageToPdf::Dimension] image dimension. pixels.
  def parse_image_dimension(path)
    image_klass = Prawn::Images.const_get(path.extname.upcase.sub(/\A\./, ""))
    image = image_klass.new(path.read)
    return ImageToPdf::Dimension.new(
      width: image.width,
      height: image.height,
    )
  end
end
