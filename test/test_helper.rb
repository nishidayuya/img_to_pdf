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

  def assert_file_content(expected_path, actual_path)
    assert_equal(Digest::MD5.file(expected_path).hexdigest,
                 Digest::MD5.file(actual_path).hexdigest,
                 "#{expected_path} != #{actual_path}")
  end
end
