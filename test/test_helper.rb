require "simplecov"
require "simplecov-lcov"
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
end
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter,
]
SimpleCov.start

require "digest/md5"
require "tempfile"

require "test/unit"

require "img_to_pdf"

TOP_SRC_PATH = Pathname(__dir__).parent
TEST_ASSETS_PATH = TOP_SRC_PATH / "test/assets"

class TestCase < Test::Unit::TestCase
  def self.setup_tmp_path(instance_variable_name)
    setup do
      instance_variable_set(
        instance_variable_name,
        Pathname(Tempfile.open(&:path)),
      )
    end
  end

  private

  def assert_pdf_content(expected_path, actual_path)
    expected_digest = pdf_content_digest(expected_path)
    actual_digest = pdf_content_digest(actual_path)

    if !ENV["UPDATE_EXPECTED_PDF_IF_SAME_IMAGES"].to_s.empty? &&
       expected_digest != actual_digest &&
       update_expected_if_same_images(expected_path, actual_path)
      expected_digest = pdf_content_digest(expected_path)
      actual_digest = pdf_content_digest(actual_path)
    end

    assert_equal(
      expected_digest,
      actual_digest,
      "#{expected_path} != #{actual_path}",
    )
  end

  # need following commands:
  #
  # - pdftocairo: apt install -y poppler-utils
  # - pixelmatch: npm install -g pixelmatch
  def update_expected_if_same_images(expected_path, actual_path)
    Dir.mktmpdir do |d|
      tmp_root = Pathname(d)
      expected_paths = create_png_images_from_pdf(expected_path, tmp_root, "expected")
      actual_paths = create_png_images_from_pdf(actual_path, tmp_root, "actual")
      if expected_paths.length != actual_paths.length
        puts("number of paths are different: expected=#{expected_paths.length} actual=#{actual_paths.length}")
        return false
      end
      expected_paths.zip(actual_paths).each do |expected, actual|
        if !system("pixelmatch #{expected} #{actual}")
          puts("different page is detected: expected=#{expected} actual=#{actual}")
          return false
        end
      end
    end
    FileUtils.cp(actual_path, expected_path)
    return true
  end

  def create_png_images_from_pdf(pdf_path, output_root, filename_prefix)
    system(*%W[pdftocairo -png #{pdf_path} #{output_root}/#{filename_prefix}], exception: true)
    paths = Pathname.glob(output_root / "#{filename_prefix}-*.png").sort
    return paths
  end

  def pdf_content_digest(pdf_path)
    content = pdf_path.binread.
                sub(%r{^(<< )/Creator <[0-9a-f]+?>}, '\\1').
                sub(/(?<=\nxref\n0 ).*(?=trailer\n)/m, "").
                sub(/^(?<=startxref\n)\d+/, "")
    return Digest::MD5.hexdigest(content)
  end
end
