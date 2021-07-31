require "test_helper"

class ImgToPdf::DimensionTest < TestCase
  sub_test_case(".from_array") do
    test("return instance from array") do
      assert_equal(
        ImgToPdf::Dimension.new(width: 1, height: 2),
        ImgToPdf::Dimension.from_array([1, 2]),
      )
    end
  end

  sub_test_case("#to_a") do
    test("return array") do
      assert_equal([1, 2], ImgToPdf::Dimension.new(width: 1, height: 2).to_a)
    end
  end

  sub_test_case("#direction") do
    data(
      "return :landscape if width is longer than height" => [
        :landscape,
        {width: 2, height: 1},
      ],
      "return :portrait if height is longer than width" => [
        :portrait,
        {width: 1, height: 2},
      ],
      "return :portrait if width == height" => [
        :portrait,
        {width: 1, height: 1},
      ],
    )
    test("") do |(returns, value)|
      assert_equal(returns, ImgToPdf::Dimension.new(**value).direction)
    end
  end

  sub_test_case("#transpose") do
    test("return transposed dimension") do
      assert_equal(
        ImgToPdf::Dimension.new(width: 2, height: 1),
        ImgToPdf::Dimension.new(width: 1, height: 2).transpose,
      )
    end
  end

  sub_test_case("#justify_direction") do
    data(
      landscape: [
        {width: 2, height: 1},
        :portrait,
      ],
      portrait: [
        {width: 1, height: 2},
        :landscape,
      ],
    )
    test("return transposed it if different direction") do |(value, direction)|
      d = ImgToPdf::Dimension.new(**value)
      assert_equal(d.transpose, d.justify_direction(direction))
    end

    data(
      landscape: [
        {width: 2, height: 1},
        :landscape,
      ],
      portrait: [
        {width: 1, height: 2},
        :portrait,
      ],
    )
    test("return dupped it if same direction") do |(value, direction)|
      d = ImgToPdf::Dimension.new(**value)
      result = d.justify_direction(direction)
      assert_equal(d, result)
      assert_not_equal(d.object_id, result.object_id)
    end
  end

  sub_test_case("#pt_to_in") do
    test("return converted it") do
      assert_equal(
        ImgToPdf::Dimension.new(
          width: ImgToPdf::Unit.convert_pt_to_in(10),
          height: ImgToPdf::Unit.convert_pt_to_in(20),
        ),
        ImgToPdf::Dimension.new(width: 10, height: 20).pt_to_in,
      )
    end
  end
end
