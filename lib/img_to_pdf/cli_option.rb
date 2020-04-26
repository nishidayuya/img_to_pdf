require "optparse"

require "img_to_pdf"

ImgToPdf::CliOption = Struct.new(
  :input_path, :output_path, :debug, :paper_size_text, :margin_pt,
  :n_horizontal_pages, :n_vertical_pages,
  keyword_init: true,
)
# Command line option model
class ImgToPdf::CliOption
  BANNER = <<~BANNER.chomp
    Usage: #{File.basename(Process.argv0)} [options] input_image_path output_pdf_path
  BANNER

  class << self
    def default
      default_margin_pt = ImgToPdf::Unit.convert_mm_to_pt(10)
      result = new(
        input_path: nil,
        output_path: nil,
        debug: false,
        paper_size_text: "a4-landscape",
        margin_pt: ImgToPdf::Margin.new(
          left: default_margin_pt,
          right: default_margin_pt,
          top: default_margin_pt,
          bottom: default_margin_pt,
        ),
        n_horizontal_pages: 1,
        n_vertical_pages: 1,
      )
      return result
    end

    def from_argv(argv, stdout: $stdout) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      result = default

      parser = OptionParser.new
      parser.version = ImgToPdf::VERSION
      parser.banner = BANNER
      parser.summary_indent = ""
      parser.separator("")
      parser.separator("Options:")
      parser.on(
        "--paper-size=SIZE",
        "specify paper size. 'a4-landscape'(default), 'b3-portrait', etc.",
      ) do |v|
        result.paper_size_text = v
      end
      parser.on(
        "--horizontal-pages=INTEGER",
        "specify number of horizontal pages. default 1.",
      ) do |v|
        result.n_horizontal_pages = ImgToPdf::IntegerParser.(v)
      end
      parser.on(
        "--vertical-pages=INTEGER",
        "specify number of vertical pages. default 1.",
      ) do |v|
        result.n_vertical_pages = ImgToPdf::IntegerParser.(v)
      end
      parser.on("--debug") do
        result.debug = true
      end

      input_path, output_path = *parser.parse(argv)
      if !output_path
        stdout.puts(parser.help)
        exit(1)
      end
      result.input_path = Pathname(input_path).expand_path
      result.output_path = Pathname(output_path).expand_path

      return result
    end
  end
end
