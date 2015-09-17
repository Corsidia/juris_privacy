require_relative 'blacklist'
require_relative 'censor_utils'

module JurisPrivacy
  # BlacklistWordsCensor
  class BlacklistWordsCensor
    include CensorUtils

    def initialize(blacklist)
      @blacklist = blacklist
    end

    def inspect(content)
      blacklist_words = content.scan(blacklist_word_regex)
      blacklist_words.map! { |word| word.gsub(/\W/, '') }

      censored_blacklist_words = {}
      blacklist_words.each do |word|
        unique_censored_word = uniquify_hash_key(censor_word(word),
                                                 censored_blacklist_words)
        censored_blacklist_words[unique_censored_word] = word
      end
      censored_blacklist_words
    end

    private

    def blacklist_word_regex
      /
        \W+
        (?:#{@blacklist.words.join('|')})
        \W+
      /xi
    end
  end
end
