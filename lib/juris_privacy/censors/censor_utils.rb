module JurisPrivacy
  # CensorUtils
  module CensorUtils
    def censor_word(word)
      "#{word[0].upcase}."
    end

    def uniquify_hash_key(original_key, hash)
      key = "#{original_key}"
      additional_letter = 'A'
      while hash.include? key
        key = "#{original_key}#{additional_letter}."
        additional_letter.next!
      end
      key
    end
  end
end
