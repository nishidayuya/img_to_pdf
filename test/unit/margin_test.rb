require "test_helper"

class ImgToPdf::MarginTest < TestCase
  sub_test_case("#to_a") do
    test("return array") do
      assert_equal(
        [10, 20, 30, 40],
        ImgToPdf::Margin.new(top: 10, right: 20, bottom: 30, left: 40).to_a,
      )
    end
  end
end
