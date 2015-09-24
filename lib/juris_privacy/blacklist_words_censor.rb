require_relative 'blacklist'
require_relative 'censor_utils'

module JurisPrivacy
  # BlacklistWordsCensor
  class BlacklistWordsCensor
    include CensorUtils

    def initialize(blacklist)
      @blacklist = blacklist
    end

    def inspect(content)
      blacklist_matches = content.scan(blacklist_word_regex)

      censored_blacklist_matches = {}
      blacklist_matches.each do |bl_match|
        unique_censored_match = uniquify_hash_key(censor_bl_match(bl_match),
                                                  censored_blacklist_matches)
        censored_blacklist_matches[unique_censored_match] = bl_match
      end
      censored_blacklist_matches
    end

    private

    def blacklist_word_regex
      /
        (?:[A-Z][a-záéíóú]{2,25}\s+)?
        (?i:#{@blacklist.words.join('|')})
        (?:\s+[A-Z][a-záéíóú]{2,25})?
      /x
    end

    def censor_bl_match(blacklist_match)
      blacklist_match_words = blacklist_match.split(/\s/)
      blacklist_match_words.map { |word| censor_word(word) }.join
    end
  end
end
