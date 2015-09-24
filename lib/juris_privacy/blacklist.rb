require_relative 'wordlist'

module JurisPrivacy
  # Blacklist
  class Blacklist < Wordlist
    def blacklisted?(word)
      include? word.downcase
    end

    def add_word(word)
      super word.downcase
    end
  end
end
