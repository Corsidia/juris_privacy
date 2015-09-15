require 'minitest/autorun'
require 'juris_privacy'

# WhitelistTest
class WhitelistTest < Minitest::Test
  def test_array_source
    whitelisted_words = %w(arena bicicletta)
    @whitelist = JurisPrivacy::Whitelist.new whitelisted_words

    %w(arena ARENA Arena bICIcletta BICICLETTA).each do |word|
      assert @whitelist.whitelisted? word
    end

    assert !@whitelist.whitelisted?('gamberini')
  end

  def test_file_source
    data_file_path = 'test/fixtures/whitelist_words_it.data'
    @whitelist = JurisPrivacy::Whitelist.new data_file_path

    %w(trota TROTA salmone salMONE Gallo cavallo).each do |word|
      assert @whitelist.whitelisted? word
    end

    assert !@whitelist.whitelisted?('lorenzo')
  end
end
