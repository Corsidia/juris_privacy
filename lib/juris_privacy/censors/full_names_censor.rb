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
      /#{common_capitalized_word} | #{strange_surname}/x
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

    def false_positive?(full_name)
      return false if @blacklist.blacklisted?(full_name)
      return true if @whitelist.whitelisted?(full_name)

      full_name_words = full_name.split(/\s/)
      full_name_words.each do |word|
        return false unless allowed_word?(word)
      end
      true
    end

    def allowed_word?(word)
      @whitelist.whitelisted?(word) && !@blacklist.blacklisted?(word)
    end
  end
end
