require_relative 'test_helper'

# TestWhitelist
class TestWhitelist < Minitest::Test
  def test_array_source
    whitelisted_words = %w(arena bicicletta)
    @whitelist = JurisPrivacy::Whitelist.new whitelisted_words

    %w(arena ARENA Arena bICIcletta BICICLETTA).each do |word|
      assert @whitelist.whitelisted? word
    end

    assert !@whitelist.whitelisted?('gamberini')
    assert_equal whitelisted_words, @whitelist.words
  end

  def test_file_source
    data_file_path = 'test/fixtures/whitelist_words_it.data'
    @whitelist = JurisPrivacy::Whitelist.new data_file_path

    %w(trota TROTA salmone salMONE Gallo cavallo).each do |word|
      assert @whitelist.whitelisted? word
    end

    assert !@whitelist.whitelisted?('lorenzo')
    assert_equal %w(cavallo trota salmone gallo), @whitelist.words
  end

  def test_wrong_source
    error = assert_raises ArgumentError do
      @whitelist = JurisPrivacy::Whitelist.new 42
    end

    expected_error_message = 'Accepts only String and Array as words source'
    assert_equal expected_error_message, error.message
  end
end
