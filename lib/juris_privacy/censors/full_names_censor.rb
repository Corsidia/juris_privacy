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
      two_words_name = /
                         #{name_word_regex}
                         \s
                         (?:#{surname_prefix_regex})?
                         #{name_word_regex}
                       /x

      multiple_words_name = /
                              #{name_word_regex}
                              (?:\s#{name_word_regex})+
                            /x

      /#{multiple_words_name}|#{two_words_name}/
    end

    def name_word_regex
      /[A-Z][a-záéíóú]{2,25}/
    end

    def surname_prefix_regex
      two_chars_prefix = /[A-Z](?:[a-z]\s|\')/
      common_prefixes = /Dell\'|Della\s|Dello\s|Del\s|Degli\s|Delle\s|Dei\s/
      /#{two_chars_prefix}|#{common_prefixes}/
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
