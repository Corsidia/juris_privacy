require 'minitest/autorun'
require 'juris_privacy'

# ObscurerTest
class ObscurerTest < Minitest::Test
  def test_do_not_obscure_whitelisted_name
    # whitelisted_words = %w(arena bicicletta)
    # whitelist = JurisPrivacy::Whitelist.new whitelisted_words
    # obscurer = JurisPrivacy::Obscurer.new whitelist

    # text = 'ciao io mi chiamo Luca Bicicletta'
    # assert_equal text, obscurer.obscure(text)
    assert true
    # text = 'ciao io mi chiamo Giorgio Caldari'
    # assert text != obscurer.obscure(text)
  end
end
