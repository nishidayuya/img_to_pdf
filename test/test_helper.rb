require "digest/md5"
require "tempfile"

require "test/unit"

require "image_to_pdf"

TOP_SRC_PATH = Pathname(__dir__).parent
TEST_ASSETS_PATH = TOP_SRC_PATH / "test/assets"

class TestCase < Test::Unit::TestCase
  def self.setup_tmp_path(instance_variable_name)
    setup do
      instance_variable_set(instance_variable_name,
                            Pathname(Tempfile.open(&:path)))
    end
  end

  private

  def assert_pdf_content(expected_path, actual_path)
    assert_equal(pdf_content_digest(expected_path),
                 pdf_content_digest(actual_path),
                 "#{expected_path} != #{actual_path}")
  end

  def pdf_content_digest(pdf_path)
    content = pdf_path.binread.
                sub(%r|^(<< )/Creator <[0-9a-f]+?>|, '\\1').
                sub(/(?<=\nxref\n0 ).*(?=trailer\n)/m, "").
                sub(/^(?<=startxref\n)\d+/, "")
    return Digest::MD5.hexdigest(content)
  end
end
