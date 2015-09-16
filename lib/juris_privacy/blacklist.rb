require_relative 'wordlist'

module JurisPrivacy
  # Blacklist
  class Blacklist < Wordlist
    def initialize(word_source = nil)
      default_data_path =
        'lib/juris_privacy/blacklist_data/blacklist_words_it.data'
      super(word_source, default_data_path)
    end

    def blacklisted?(word)
      include?(word.downcase)
    end
  end
end
