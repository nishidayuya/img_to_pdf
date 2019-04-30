require "optparse"
require "pathname"
require "tmpdir"

require "image_to_pdf"

module ImageToPdf::Cli
  extend self

  def run(argv)
    input_path, output_path = *parse_options(argv).map { |path| Pathname(path) }
    page_dimension_pt = parse_paper_size(@paper_size)

    canvas_dimension_pt = ImageToPdf::Dimension.new(
      width: ((page_dimension_pt.width - @left_margin_pt - @right_margin_pt) *
              @n_horizontal_pages),
      height: ((page_dimension_pt.height - @top_margin_pt - @top_margin_pt) *
               @n_vertical_pages),
    )
    canvas_dimension_in = canvas_dimension_pt.pt_to_in

    image_dimension_px = parse_image_dimension(input_path)
    dpi_from_width = image_dimension_px.width / canvas_dimension_in.width
    dpi_from_height = image_dimension_px.height / canvas_dimension_in.height
    canvas_dpi = [dpi_from_width, dpi_from_height].max
    canvas_scale = 72 / canvas_dpi

    tmp_path = Pathname(Dir.mktmpdir)
    tmp_image_dimension_px = ImageToPdf::Dimension.new(
      width: image_dimension_px.width / @n_horizontal_pages,
      height: image_dimension_px.height / @n_vertical_pages,
    )

    pdf = Prawn::Document.new(
      page_size: [page_dimension_pt.width, page_dimension_pt.height],
      left_margin: @left_margin_pt,
      right_margin: @right_margin_pt,
      top_margin: @top_margin_pt,
      bottom_margin: @bottom_margin_pt,
      skip_page_creation: true,
      info: {
        Creator: "image_to_pdf version #{ImageToPdf::VERSION}",
      }
    )
    @n_vertical_pages.times do |i_y|
      @n_horizontal_pages.times do |i_x|
        tmp_image_path = tmp_path / "#{i_x}-#{i_y}"

        image = MiniMagick::Image.open(input_path)
        image.crop("#{tmp_image_dimension_px.width}x#{tmp_image_dimension_px.height}+#{tmp_image_dimension_px.width * i_x}+#{tmp_image_dimension_px.height * i_y}")
        image.write(tmp_image_path)

        pdf.start_new_page
        pdf.image(
          tmp_image_path,
          scale: canvas_scale,
          at: [0, canvas_dimension_pt.height / @n_vertical_pages],
        )
      end
    end
    pdf.render_file(output_path)
  ensure
    tmp_path&.rmtree
  end

  private

  BANNER = <<EOS.chomp
Usage: #{File.basename(Process.argv0)} [options] input_image_path output_pdf_path
EOS

  # @param [Array<String>] argv program arguments.
  # @return [Array<(String, String)>] `[input image path, output pdf path]`.
  def parse_options(argv)
    @paper_size = "a4-landscape"
    @n_vertical_pages = 1
    @n_horizontal_pages = 1
    @left_margin_pt = @right_margin_pt = @top_margin_pt = @bottom_margin_pt =
      ImageToPdf::Unit.convert_mm_to_pt(10)

    parser = OptionParser.new
    parser.version = ImageToPdf::VERSION
    parser.banner = BANNER
    parser.separator("")
    parser.separator("Options:")
    parser.summary_indent = ""
    parser.on("--paper-size=SIZE",
              "specify paper size. 'a4-landscape'(default), 'b3-portrait', etc.") do |v|
      @paper_size = v
    end
    parser.on("--vertical-pages=INTEGER",
              "specify number of vertical pages. default 1.") do |v|
      @n_vertical_pages = ImageToPdf::IntegerParser.(v)
    end
    parser.on("--horizontal-pages=INTEGER",
              "specify number of horizontal pages. default 1.") do |v|
      @n_horizontal_pages = ImageToPdf::IntegerParser.(v)
    end

    input_path, output_path = *parser.parse(argv)
    if !output_path
      puts(parser.help)
      exit(1)
    end
    return input_path, output_path
  end

  # @param [String] paper_size_text "a4-landscape", "b3-portrait", etc.
  # @return [ImageToPdf::Dimension] paper dimension. points.
  def parse_paper_size(paper_size_text)
    paper_size, direction = *paper_size_text.split("-")
    direction = direction.downcase.to_sym
    if !%i[landscape portrait].include?(direction)
      raise({direction: direction}.inspect)
    end
    raw_size_pt = PDF::Core::PageGeometry::SIZES[paper_size.upcase]
    if !raw_size_pt
      raise({paper_size_text: paper_size_text}.inspect)
    end

    paper_dimension_pt = ImageToPdf::Dimension.from_array(raw_size_pt)
    paper_dimension_pt = paper_dimension_pt.justify_direction(direction)

    return paper_dimension_pt
  end

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
