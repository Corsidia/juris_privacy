require_relative 'censor_utils'

module JurisPrivacy
  # UpcasetWordsCensor
  class UpcaseWordsCensor
    include CensorUtils

    def inspect(content)
      upcase_words = content.scan(upcase_word_regex)

      censored_upcase_words = {}
      upcase_words.each do |word|
        unique_censored_word = uniquify_hash_key(censor_word(word),
                                                 censored_upcase_words)
        censored_upcase_words[unique_censored_word] = word
      end
      censored_upcase_words
    end

    private

    def upcase_word_regex
      /[A-Z]{2,}/
    end
  end
end
