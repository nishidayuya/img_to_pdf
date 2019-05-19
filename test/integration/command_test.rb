require "test_helper"

class CommandTest < TestCase
  COMMAND =
    %W[ruby -I#{TOP_SRC_PATH / "lib"} #{TOP_SRC_PATH / "exe/image_to_pdf"}]

  setup_tmp_path(:@output_path)

  test("default") do
    run_command(TEST_ASSETS_PATH / "i.png", @output_path)
    assert_file_content(TEST_ASSETS_PATH / "i-default.pdf", @output_path)
  end

  test("with arguments") do
    run_command(
      *%w[
        --paper-size=b5-portrait
        --horizontal-pages=3
        --vertical-pages=4
      ],
      TEST_ASSETS_PATH / "i.png",
      @output_path,
    )
    assert_file_content(TEST_ASSETS_PATH / "i-b5-portrait-3x4.pdf", @output_path)
  end

  private

  def run_command(*args)
    return system(*COMMAND, *args.map(&:to_s), exception: true)
  end
end
