require_relative 'whitelist'
require_relative 'blacklist'
require_relative 'censors/full_names_censor'
require_relative 'censors/blacklist_words_censor'
require_relative 'censors/tax_codes_censor'

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
      new_content = content.dup
      global_censored_words = {}
      censors.each do |censor|
        censored_words = censor.inspect new_content
        global_censored_words.merge! censored_words
        update_blacklist(censored_words.values)
        new_content = delete_already_censored_words(new_content,
                                                    censored_words.values)
      end
      global_censored_words
    end

    def obscure_text(text)
      censored_data = inspect text

      censored_data.each do |censored_datum, datum|
        text.gsub!(datum, censored_datum)
      end
      text
    end

    private

    def censors
      [
        FullNamesCensor.new(@whitelist, @blacklist),
        BlacklistWordsCensor.new(@blacklist),
        TaxCodesCensor.new
      ]
    end

    def delete_already_censored_words(content, censored_words)
      return content if censored_words.empty?
      clean_regex = /#{censored_words.join('|')}/
      content.gsub(clean_regex, '***')
    end

    def update_blacklist(dangerous_things)
      dangerous_things.each do |dangerous_thing|
        @blacklist.add_word dangerous_thing

        dangerous_thing_words = dangerous_thing.split(/\s/)
        dangerous_thing_words.each { |word| @blacklist.add_word word }
      end
    end
  end
end
