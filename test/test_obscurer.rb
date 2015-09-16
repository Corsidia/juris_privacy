require 'minitest/autorun'
require 'juris_privacy'

# ObscurerTest
class ObscurerTest < Minitest::Test
  def setup
    whitelisted_words = %w(arena bicicletta)
    whitelist = JurisPrivacy::Whitelist.new whitelisted_words
    blacklisted_words = %w(marco paolo luca)
    blacklist = JurisPrivacy::Blacklist.new blacklisted_words
    @obscurer = JurisPrivacy::Obscurer.new whitelist, blacklist
  end

  # Don't censor whitelisted words
  def test_whitelist
    text = 'ciao io mi chiamo Lattuga Bicicletta'
    expected_censored_data = {}
    assert_equal expected_censored_data, @obscurer.censored_data_for(text)
  end

  # Censor blacklisted words
  def test_blacklist
    text = 'ciao io mi chiamo luca paoli'
    expected_censored_data = { 'L***' => 'luca' }
    assert_equal expected_censored_data, @obscurer.censored_data_for(text)
  end

  # Blacklist has priority over Whitelist
  def test_black_and_white_priority
    text = 'ciao io mi chiamo Luca Bicicletta'
    expected_censored_data = { 'L*** B*********' => 'Luca Bicicletta' }
    assert_equal expected_censored_data, @obscurer.censored_data_for(text)
  end

  # Names with same initials and number of letters
  # are identified by trailing '(n)'
  def test_name_collisions
    text = 'ciao io mi chiamo Luca Baffoni '\
           'e questa è la mia amica Lara Bassini'
    expected_censored_data = { 'L*** B******' => 'Luca Baffoni',
                               'L*** B******(1)' => 'Lara Bassini' }
    assert_equal expected_censored_data, @obscurer.censored_data_for(text)
  end
end
