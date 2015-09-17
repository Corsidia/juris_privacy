module JurisPrivacy
  # CensorUtils
  module CensorUtils
    def censor_word(word)
      "#{word[0].upcase}#{'*' * (word.length - 1)}"
    end

    def uniquify_hash_key(key, hash)
      n = 0
      while hash.include? key
        n += 1
        key = "#{key}(#{n})"
      end
      key
    end
  end
end
