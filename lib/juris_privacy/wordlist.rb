module JurisPrivacy
  # Wordlist
  class Wordlist
    def initialize(word_source, default_data_path)
      if word_source.is_a? Array
        @words = word_source
      elsif word_source.is_a? String
        @data_path = word_source
      else
        @data_path = default_data_path
      end
    end

    def words
      @words ||= File
                 .readlines(@data_path)
                 .collect(&:chomp)
                 .compact
    end

    def include?(word)
      words.include?(word)
    end
  end
end
