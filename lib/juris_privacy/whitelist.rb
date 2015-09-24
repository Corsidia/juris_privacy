require_relative 'wordlist'

module JurisPrivacy
  # Whitelist
  class Whitelist < Wordlist
    def whitelisted?(word)
      include?(word.downcase)
    end

    def add_word(word)
      super word.downcase
    end
  end
end
