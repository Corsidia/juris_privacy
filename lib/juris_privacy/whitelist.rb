require_relative 'wordlist'

module JurisPrivacy
  # Whitelist
  class Whitelist < Wordlist
    def initialize(word_source = nil)
      default_data_path =
        'lib/juris_privacy/whitelist_data/whitelist_words_it.data'
      super(word_source, default_data_path)
    end

    def whitelisted?(word)
      include?(word.downcase)
    end
  end
end
