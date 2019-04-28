require "test_helper"

class CommandTest < TestCase
  COMMAND =
    %W[ruby -I#{TOP_SRC_PATH / "lib"} #{TOP_SRC_PATH / "exe/image_to_pdf"}]
  TEST_ASSETS_PATH = TOP_SRC_PATH / "test/assets"

  setup do
    @output_path = Pathname(Tempfile.open(&:path))
  end

  test("default") do
    run_command(TEST_ASSETS_PATH / "i.png", @output_path)
    assert_file_content(TEST_ASSETS_PATH / "i-default.pdf", @output_path)
  end

  test("with arguments") do
    run_command(
      TEST_ASSETS_PATH / "i.png",
      *%w[
        --paper-size=b5-portrait
        --horizontal-pages=3
        --vertical-pages=4
      ],
      @output_path,
    )
    assert_file_content(TEST_ASSETS_PATH / "i-b5-portrait-3x4.pdf", @output_path)
  end

  private

  def assert_file_content(expected_path, actual_path)
    assert_equal(Digest::MD5.file(expected_path).hexdigest,
                 Digest::MD5.file(actual_path).hexdigest,
                 "#{expected_path} != #{actual_path}")
  end

  def run_command(*args)
    return system(*COMMAND, *args.map(&:to_s), exception: true)
  end
end
