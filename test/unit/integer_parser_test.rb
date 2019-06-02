require "test_helper"

class ImgToPdf::IntegerParserTest < TestCase
  test("'123' is parsable") do
    assert_equal(123, ImgToPdf::IntegerParser.("123"))
  end

  test("'a123' is not parsable") do
    assert_raise(ImgToPdf::ParserError) do
      ImgToPdf::IntegerParser.("a123")
    end
  end
end
