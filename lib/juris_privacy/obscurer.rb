require_relative 'whitelist'
require_relative 'blacklist'

module JurisPrivacy
  # Obscurer
  class Obscurer
    WHITELIST_DATA_PATH =
      'lib/juris_privacy/whitelist_data/whitelist_words_it.data'
    BLACKLIST_DATA_PATH =
      'lib/juris_privacy/blacklist_data/blacklist_words_it.data'

    def initialize(whitelist = Whitelist.new(WHITELIST_DATA_PATH),
                   blacklist = Blacklist.new(BLACKLIST_DATA_PATH))
      @whitelist = whitelist
      @blacklist = blacklist
    end

    def censored_data_for(content)
      censored_full_names = censored_full_names_for content

      # Ensure that all blacklisted words in content have been censored
      already_detected_regex = /#{censored_full_names.values.join('|')}/
      new_content = content.gsub(already_detected_regex, '')
      censored_blacklist_words = censored_blacklist_words_for new_content

      # Kill everything that might be dangerous
      already_detected_regex = /#{censored_blacklist_words.values.join('|')}/
      new_content = new_content.gsub(already_detected_regex, '')
      killed_words = killed_words_for new_content

      censored_full_names
        .merge(censored_blacklist_words)
        .merge(killed_words)
    end

    def killed_words_for(content)
      censored_upcase_words_for content
    end

    def censored_upcase_words_for(content)
      upcase_word_regex = /[A-Z]{2,}/
      upcase_words = content.scan(upcase_word_regex)

      censored_upcase_words = {}
      upcase_words.each do |word|
        unique_censored_word = uniquify_hash_key(censor_word(word),
                                                 censored_upcase_words)
        censored_upcase_words[unique_censored_word] = word
      end
      censored_upcase_words
    end

    def censored_full_names_for(content)
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

    def censored_blacklist_words_for(content)
      blacklist_word_regex = /#{@blacklist.words.join('|')}/
      blacklist_words = content.scan(blacklist_word_regex)

      censored_blacklist_words = {}
      blacklist_words.each do |word|
        unique_censored_word = uniquify_hash_key(censor_word(word),
                                                 censored_blacklist_words)
        censored_blacklist_words[unique_censored_word] = word
      end
      censored_blacklist_words
    end

    def obscure_text(text)
      censored_data = censored_data_for text

      censored_data.each do |censored_datum, datum|
        text.gsub!(datum, censored_datum)
      end
      text
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

    def censor_word(word)
      "#{word[0].upcase}#{'*' * (word.length - 1)}"
    end

    def censor_full_name(full_name)
      full_name_words = full_name.split(/\s/)
      full_name_words.collect { |word| censor_word(word) }.join(' ')
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
