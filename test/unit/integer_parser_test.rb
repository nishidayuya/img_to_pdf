require "test_helper"

class ImageToPdf::IntegerParserTest < TestCase
  test("'123' is parsable") do
    assert_equal(123, ImageToPdf::IntegerParser.("123"))
  end

  test("'a123' is not parsable") do
    assert_raise(ImageToPdf::ParserError) do
      ImageToPdf::IntegerParser.("a123")
    end
  end
end
