require "test_helper"

class ImgToPdf::FitPageDocumentTest < TestCase
  sub_test_case(".render_file") do
    setup_tmp_path(:@output_path)

    data {
      margin_length_pt = ImgToPdf::Unit.convert_mm_to_pt(10)
      margin_pt = ImgToPdf::Margin.new(
        top: margin_length_pt,
        right: margin_length_pt,
        bottom: margin_length_pt,
        left: margin_length_pt,
      )
      image = ImgToPdf::Image.from_path(TEST_ASSETS_PATH / "i.png")
      [
        [
          "i-default.pdf",
          "a4-landscape",
          {},
        ],
        [
          "i-b5-portrait-3x4.pdf",
          "b5-portrait",
          {n_horizontal_pages: 3, n_vertical_pages: 4},
        ],
      ].each.with_object({}) do |(expected_filename, page_size_text, args), h|
        h[expected_filename] = [
          args.merge(
            page_dimension_pt: ImgToPdf::PaperSizeParser.(page_size_text),
            margin_pt: margin_pt,
            image: image,
          ),
          TEST_ASSETS_PATH / expected_filename,
        ]
      end
    }
    test("render PDF file") do |(args, expected_path)|
      ImgToPdf::FitPageDocument.create(**args).render_file(@output_path)
      assert_pdf_content(expected_path, @output_path)
    end
  end
end
