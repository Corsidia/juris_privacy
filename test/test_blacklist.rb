require_relative 'test_helper'

# TestBlacklist
class TestBlacklist < Minitest::Test
  def test_array_source
    blacklisted_words = %w(lorenzo francesco)
    @blacklist = JurisPrivacy::Blacklist.new blacklisted_words

    %w(lorenzo Lorenzo fraNCESCO FRANCESCO).each do |word|
      assert @blacklist.blacklisted? word
    end

    assert !@blacklist.blacklisted?('missile')
    assert_equal blacklisted_words, @blacklist.words
  end

  def test_file_source
    data_file_path = 'test/fixtures/blacklist_words_it.data'
    @blacklist = JurisPrivacy::Blacklist.new data_file_path

    %w(franco Franco fraNCO giulio GIULIO marco angelo angELO).each do |word|
      assert @blacklist.blacklisted? word
    end

    assert !@blacklist.blacklisted?('pappardella')
    assert_equal %w(marco giulio franco angelo), @blacklist.words
  end

  def test_wrong_source
    error = assert_raises ArgumentError do
      @blacklist = JurisPrivacy::Blacklist.new 42
    end

    expected_error_message = 'Accepts only String and Array as words source'
    assert_equal expected_error_message, error.message
  end
end
