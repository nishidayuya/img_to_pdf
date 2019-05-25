require "tmpdir"

require "image_to_pdf"

module ImageToPdf::Cli
  extend self

  def run(argv)
    option = ImageToPdf::CliOption.from_argv(argv)
    page_dimension_pt = ImageToPdf::PaperSizeParser.(option.paper_size_text)
    input_image = ImageToPdf::Image.from_path(option.input_path)
    document = ImageToPdf::FitPageDocument.create(
      page_dimension_pt: page_dimension_pt,
      margin_pt: option.margin_pt,
      n_horizontal_pages: option.n_horizontal_pages,
      n_vertical_pages: option.n_vertical_pages,
      image: input_image,
    )
    document.render_file(option.output_path)
  rescue ImageToPdf::Error => e
    raise if option.debug
    STDERR.puts("#{e.class.name}: #{e.message}")
    exit(1)
  end
end
