require 'minitest/autorun'
require 'juris_privacy'

# BlacklistTest
class BlacklistTest < Minitest::Test
  def test_array_source
    blacklisted_words = %w(lorenzo francesco)
    @blacklist = JurisPrivacy::Blacklist.new blacklisted_words

    %w(lorenzo Lorenzo fraNCESCO FRANCESCO).each do |word|
      assert @blacklist.blacklisted? word
    end

    assert !@blacklist.blacklisted?('missile')
  end

  def test_file_source
    data_file_path = 'test/fixtures/blacklist_words_it.data'
    @blacklist = JurisPrivacy::Blacklist.new data_file_path

    %w(franco Franco fraNCO giulio GIULIO marco angelo angELO).each do |word|
      assert @blacklist.blacklisted? word
    end

    assert !@blacklist.blacklisted?('pappardella')
  end
end
