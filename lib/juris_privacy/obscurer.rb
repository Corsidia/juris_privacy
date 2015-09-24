require_relative 'whitelist'
require_relative 'blacklist'
require_relative 'censors/full_names_censor'
require_relative 'censors/blacklist_words_censor'

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

    def inspect(content)
      censored_full_names = full_names_inspect content
      update_blacklist_with_full_names(censored_full_names.values)

      new_content = delete_already_censored_words(content,
                                                  censored_full_names.values)
      censored_blacklist_words = blacklist_words_inspect new_content

      censored_full_names
        .merge(censored_blacklist_words)
    end

    def obscure_text(text)
      censored_data = inspect text

      censored_data.each do |censored_datum, datum|
        text.gsub!(datum, censored_datum)
      end
      text
    end

    # private

    def full_names_inspect(content)
      full_names_censor = FullNamesCensor.new @whitelist, @blacklist
      full_names_censor.inspect content
    end

    def blacklist_words_inspect(content)
      blacklist_words_censor = BlacklistWordsCensor.new @blacklist
      blacklist_words_censor.inspect content
    end

    def delete_already_censored_words(content, censored_words)
      return content if censored_words.empty?
      clean_regex = /#{censored_words.join('|')}/
      content.gsub(clean_regex, '***')
    end

    def update_blacklist_with_full_names(full_names)
      full_names.each do |full_name|
        @blacklist.add_word(full_name)

        full_name_words = full_name.split(/\s/)
        full_name_words.each { |word| @blacklist.add_word(word) }
      end
    end
  end
end
