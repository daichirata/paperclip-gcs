require "test_helper"

class Paperclip::GcsTest < Minitest::Test
  def test_that_it_has_a_version_number
    assert_equal ::Paperclip::Gcs::VERSION, '0.3.0'
  end
end
