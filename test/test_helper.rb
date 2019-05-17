require "digest/md5"
require "tempfile"

require "test/unit"

require "image_to_pdf"

TOP_SRC_PATH = Pathname(__dir__).parent
TEST_ASSETS_PATH = TOP_SRC_PATH / "test/assets"

class TestCase < Test::Unit::TestCase
end
