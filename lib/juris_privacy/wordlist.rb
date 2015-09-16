module JurisPrivacy
  # Wordlist
  class Wordlist
    def initialize(words_source)
      case words_source
      when Array then @words = words_source
      when String then @words = File
                                .readlines(words_source)
                                .collect(&:chomp)
                                .compact
      else fail ArgumentError,
                'Accepts only String and Array as words source'
      end
    end

    def include?(word)
      words.include?(word)
    end

    attr_reader :words
  end
end
