require_relative 'whitelist'
require_relative 'blacklist'
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
      name_regex = /[A-Z][a-záéíóú]{2,25}\s/
      surname_regex = /[A-Z][a-záéíóú]{2,25}/
      surname_prefix_regex = /[A-Z](?:[a-z]\s|\')/
      /
        #{name_regex}
        (?:#{surname_prefix_regex})?
        #{surname_regex}
      /x
    end

    def false_positive?(full_name)
      full_name_words = full_name.split(/\s/)
      name = full_name_words.first
      surname = full_name_words.last

      return false if @blacklist.blacklisted?(full_name) ||
                      @blacklist.blacklisted?(name) ||
                      @blacklist.blacklisted?(surname)

      @whitelist.whitelisted?(full_name) ||
        @whitelist.whitelisted?(name) ||
        @whitelist.whitelisted?(surname)
    end

    def censor_full_name(full_name)
      full_name_words = full_name.split(/\s/)
      full_name_words.map { |word| censor_word(word) }.join(' ')
    end
  end
end
