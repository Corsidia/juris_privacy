require_relative 'test_helper'

# TestObscurer
class TestObscurer < Minitest::Test
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

  def test_name_with_prefixes
    text = 'ciao io mi chiamo Maria De Filippi, il mio amico Michele D\'Ubaldo'
    expected_censored_data = { 'M**** D* F******' => 'Maria De Filippi',
                               'M****** D*******' => 'Michele D\'Ubaldo' }
    assert_equal expected_censored_data, @obscurer.censored_data_for(text)
  end

  # rubocop:disable Metrics/MethodLength
  def test_misc
    text = 'ciao io mi chiamo luca paoli, qui c\'è un sacco di Gente CHE NON '\
           'conosco nemmeno TANTO Bene, ci sono per esempio marco di cui '\
           'non ricordo il cognome, Marco Carta, Luca Carboni, '\
           'Maria De Filippi, Antonio Conte, PIppo Baudo... e per finire '\
           'l\'ospite speciale di questa serata è Raffaella Carrà'
    expected_censored_data = { 'L***' => 'luca',
                               'M****' => 'marco',
                               'M**** C****' => 'Marco Carta',
                               'L*** C******' => 'Luca Carboni',
                               'A****** C****' => 'Antonio Conte',
                               'R******** C***' => 'Raffaella Carr',
                               'C**' => 'CHE',
                               'N**' => 'NON',
                               'T****' => 'TANTO',
                               'I*** B****' => 'Ippo Baudo',
                               'M**** D* F******' => 'Maria De Filippi' }
    assert_equal expected_censored_data, @obscurer.censored_data_for(text)
  end

  def test_obscure_text
    text = 'ciao io mi chiamo Michele Ferrucci, la mia amica invece '\
           'si chiama Michela Falcioni'
    expected_obscured_text = 'ciao io mi chiamo M****** F*******, '\
                             'la mia amica invece si chiama M****** F*******(1)'
    assert_equal expected_obscured_text, @obscurer.obscure_text(text)
  end
end
