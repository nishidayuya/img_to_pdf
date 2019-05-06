require "test_helper"

class ImageToPdf::CliOptionTest < TestCase
  sub_test_case(".from_argv") do
    test("") do
      expected = ImageToPdf::CliOption.default
      expected.paper_size_text = "b5-portrait"
      expected.n_horizontal_pages = 3
      expected.n_vertical_pages = 4
      expected.debug = true
      expected.input_path = Pathname("/path/to/input.png")
      expected.output_path = TOP_SRC_PATH / "output.pdf"
      actual = assert_nothing_raised {
        ImageToPdf::CliOption.from_argv(%w[
          --paper-size=b5-portrait
          --horizontal-pages=3
          --vertical-pages=4
          --debug
          /path/to/input.png ./output.pdf
        ])
      }
      assert_equal(expected, actual)
    end
  end
end
