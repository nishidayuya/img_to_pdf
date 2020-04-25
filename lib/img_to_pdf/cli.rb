require "tmpdir"

require "img_to_pdf"

# Command line program entrypoint
module ImgToPdf::Cli
  module_function

  def run(argv) # rubocop:disable Metrics/AbcSize
    option = ImgToPdf::CliOption.from_argv(argv)
    page_dimension_pt = ImgToPdf::PaperSizeParser.(option.paper_size_text)
    input_image = ImgToPdf::Image.from_path(option.input_path)
    document = ImgToPdf::FitPageDocument.create(
      page_dimension_pt: page_dimension_pt,
      margin_pt: option.margin_pt,
      n_horizontal_pages: option.n_horizontal_pages,
      n_vertical_pages: option.n_vertical_pages,
      image: input_image,
    )
    document.render_file(option.output_path)
  rescue ImgToPdf::Error => e
    raise if option.debug

    warn("#{e.class.name}: #{e.message}")
    exit(1)
  end
end
