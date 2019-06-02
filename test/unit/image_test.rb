require "test_helper"

class ImgToPdf::ImageTest < TestCase
  INPUT_PATH = TEST_ASSETS_PATH / "i.png"

  sub_test_case(".from_path") do
    test("return ImgToPdf::Image") do
      assert_equal(INPUT_PATH, ImgToPdf::Image.from_path(INPUT_PATH).path)
    end
  end

  sub_test_case("#dimension_px") do
    test("return dimension") do
      assert_equal(ImgToPdf::Dimension.new(width: 640, height: 480),
                   ImgToPdf::Image.new(INPUT_PATH).dimension_px)
    end
  end

  sub_test_case("#crop") do
    test("call yield with sub image") do
      block_is_called = false
      ImgToPdf::Image.new(INPUT_PATH).crop(10, 20, 123, 456) do |sub_image|
        assert_equal(ImgToPdf::Dimension.new(width: 123, height: 456),
                     sub_image.dimension_px)
        assert_instance_of(Pathname, sub_image.path)
        assert_not_equal(INPUT_PATH, sub_image.path)
        block_is_called = true
      end
      assert_equal(true, block_is_called)
    end
  end
end
