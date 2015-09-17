require_relative 'whitelist'
require_relative 'blacklist'
require_relative 'full_names_censor'
require_relative 'blacklist_words_censor'
require_relative 'upcase_words_censor'

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

      # Ensure that all blacklisted words in content have been censored
      new_content = delete_censored_words(content, censored_full_names)
      censored_blacklist_words = blacklist_words_inspect new_content

      # Kill everything that might be dangerous
      new_content = delete_censored_words(new_content, censored_blacklist_words)
      censored_upcase_words = upcase_words_inspect new_content

      censored_full_names
        .merge(censored_blacklist_words)
        .merge(censored_upcase_words)
    end

    def obscure_text(text)
      censored_data = inspect text

      censored_data.each do |censored_datum, datum|
        text.gsub!(datum, censored_datum)
      end
      text
    end

    private

    def full_names_inspect(content)
      full_names_censor = FullNamesCensor.new @whitelist, @blacklist
      full_names_censor.inspect content
    end

    def blacklist_words_inspect(content)
      blacklist_words_censor = BlacklistWordsCensor.new @blacklist
      blacklist_words_censor.inspect content
    end

    def upcase_words_inspect(content)
      upcase_words_censor = UpcaseWordsCensor.new
      upcase_words_censor.inspect content
    end

    def delete_censored_words(content, censored_words)
      clean_regex = /#{censored_words.values.join('|')}/
      content.gsub(clean_regex, '')
    end
  end
end
