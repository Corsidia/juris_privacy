require_relative 'whitelist'
require_relative 'blacklist'

module JurisPrivacy
  # Obscurer
  class Obscurer
    def initialize(whitelist = Whitelist.new, blacklist = Blacklist.new)
      @whitelist = whitelist
      @blacklist = blacklist
    end

    def censored_data_for(content)
      censored_full_names = censored_full_names_for content

      # Ensure that all blacklisted words in content have been censored
      already_detected_regex = /#{censored_full_names.values.join('|')}/
      new_content = content.gsub(already_detected_regex, '')
      censored_words = censored_words_for new_content

      # Kill everything that might be dangerous
      already_detected_regex = /#{censored_words.values.join('|')}/
      new_content = new_content.gsub(already_detected_regex, '')
      killed_words = killed_words_for new_content

      censored_full_names
        .merge(censored_words)
        .merge(killed_words)
    end

    def killed_words_for(content)
      upcase_word_regex = /[A-Z]{2,}/
      upcase_words = content.scan(upcase_word_regex)

      killed_words = {}
      upcase_words.each do |word|
        unique_killed_word = uniquify_hash_key(censor_word(word),
                                               killed_words)
        killed_words[unique_killed_word] = word
      end
      killed_words
    end

    def censored_full_names_for(content)
      name_surname_regex = /[A-Z][a-záéíóú]{2,25}\s[A-Z][a-záéíóú]{2,25}/
      full_names = content.scan(name_surname_regex)

      censored_full_names = {}
      full_names.each do |full_name|
        next if false_positive?(full_name)

        unique_censored_name = uniquify_hash_key(censor_full_name(full_name),
                                                 censored_full_names)
        censored_full_names[unique_censored_name] = full_name
      end
      censored_full_names
    end

    def censored_words_for(content)
      blacklisted_regex = /#{@blacklist.words.join('|')}/
      blacklisted_words = content.scan(blacklisted_regex)

      censored_words = {}
      blacklisted_words.each do |word|
        unique_censored_word = uniquify_hash_key(censor_word(word),
                                                 censored_words)
        censored_words[unique_censored_word] = word
      end
      censored_words
    end

    def obscure_text(text)
      censored_data = censored_data_for text

      censored_data.each do |censored_datum, datum|
        text.gsub!(datum, censored_datum)
      end
      text
    end

    def obscure_file(src_path, dst_path)
      file_content = File.open(src_path, 'rb', &read)
      obscured_content = obscure_text file_content

      File.open(dst_path, 'w') { |f| f.puts(obscured_content) }
    end

    private

    def false_positive?(full_name)
      name, surname = full_name.split(/\s/)

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
      name, surname = full_name.split(/\s/)
      "#{censor_word(name)} #{censor_word(surname)}"
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
