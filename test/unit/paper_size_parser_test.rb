require "test_helper"

require "image_to_pdf/paper_size_parser"

class ImageToPdf::PaperSizeParserTest < TestCase
  data {
    {
      "a4-landscape" => PDF::Core::PageGeometry::SIZES["A4"].reverse,
      "b3-portrait" => PDF::Core::PageGeometry::SIZES["B3"],
    }.each.with_object({}) do |(paper_size_text, expected_size_ary), h|
      h[paper_size_text] = {
        paper_size_text: paper_size_text,
        expected: ImageToPdf::Dimension.from_array(expected_size_ary),
      }
    end
  }
  test("parsable") do |paper_size_text:, expected:|
    assert_equal(expected, ImageToPdf::PaperSizeParser.(paper_size_text))
  end

  data {
    %w[x5-landscape a4-foobar].each.with_object({}) do |s, h|
      h[s] = s
    end
  }
  test("not parsable") do |paper_size_text|
    assert_raise(ImageToPdf::ParserError) do
      ImageToPdf::PaperSizeParser.(paper_size_text)
    end
  end
end
