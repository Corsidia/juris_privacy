module JurisPrivacy
  # Whitelist
  class Whitelist
    DEFAULT_DATA_PATH =
      'lib/juris_privacy/whitelist_data/whitelist_words_it.data'

    def initialize(word_source = nil)
      if word_source.is_a? Array
        @words = word_source
      elsif word_source.is_a? String
        @data_path = word_source
      else
        @data_path = DEFAULT_DATA_PATH
      end
    end

    def words
      @words ||= File
                 .readlines(@data_path)
                 .collect(&:chomp)
                 .compact
    end

    def whitelisted?(word)
      words.include?(word.downcase)
    end
  end
end
