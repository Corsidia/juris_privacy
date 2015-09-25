require_relative '../whitelist'
require_relative '../blacklist'
require_relative 'censor_utils'

module JurisPrivacy
  # FullNameCensor
  class FullNamesCensor
    include CensorUtils

    def initialize(whitelist, blacklist)
      @whitelist = whitelist
      @blacklist = blacklist
    end

    def inspect(content)
      full_names = content.scan(full_name_regex)

      censored_full_names = {}
      full_names.each do |full_name|
        next if false_positive?(full_name)

        unique_censored_name = uniquify_hash_key(censor_full_name(full_name),
                                                 censored_full_names)
        censored_full_names[unique_censored_name] = full_name
      end
      censored_full_names
    end

    private

    def full_name_regex
      /
          #{full_name_word}
          (?: \s#{full_name_word} )+
      /x
    end

    def full_name_word
      /#{common_capitalized_word} | #{strange_surname} | #{upcase_word}/x
    end

    def upcase_word
      # also matches words like: 'DI', 'DA', 'DE'...
      /[A-Z']{2,25}/x
    end

    def common_capitalized_word
      # also matches words like: 'Di', 'Da', 'De'...
      /[A-Z][a-záéíóú]{1,25}/x
    end

    def strange_surname
      /[A-Z]'#{common_capitalized_word} | Dell'#{common_capitalized_word}/x
    end

    def censor_full_name(full_name)
      censor_all = contains_blacklist_words?(full_name)

      full_name_words = full_name.split(/\s/)
      full_name_words.map do |word|
        censor_all || !allowed_word?(word) ? censor_word(word) : word
      end.join
    end

    def contains_blacklist_words?(full_name)
      full_name_words = full_name.split(/\s/)
      full_name_words.each do |word|
        return true if @blacklist.blacklisted?(word)
      end
      false
    end

    # returns true if full_name is not a person name
    def false_positive?(full_name)
      # if every word in full_name is uppercase (es. 'GUIDO FORTE')
      # we cannot distinguish between a name and two common words
      # NOTE: this issue is partially resolved by adding already detected names
      #       to blacklist: if the name is written in downcase at least one time
      #       in the examinated text it will be detected by BlacklistWordsCensor
      return true if upcase?(full_name)

      return false if @blacklist.blacklisted?(full_name)
      return true if @whitelist.whitelisted?(full_name)

      full_name_words = full_name.split(/\s/)
      full_name_words.each do |word|
        return false unless allowed_word?(word)
      end
      true
    end

    def upcase?(text)
      text.upcase == text
    end

    def allowed_word?(word)
      @whitelist.whitelisted?(word) && !@blacklist.blacklisted?(word)
    end
  end
end
