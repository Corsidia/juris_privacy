require_relative 'whitelist'
require_relative 'blacklist'

module JurisPrivacy
  # Obscurer
  class Obscurer
    NAME_SURNAME_REGEX = /[A-Z][a-z]{2,25}\s[A-Z][a-z]{2,25}/

    def initialize(whitelist = Whitelist.new, blacklist = Blacklist.new)
      @whitelist = whitelist
      @blacklist = blacklist
    end

    def obscure(content)
      full_names = content.scan(NAME_SURNAME_REGEX)

      full_names.each do |full_name|
        next if false_positive?(full_name)
        content.gsub!(full_name, initials_of(full_name))
      end
      content
    end

    def obscure_file(src_path, dst_path)
      file_content = File.open(src_path, 'rb', &read)
      obscured_content = obscure file_content
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

    def initial_of(word)
      "#{word[0].upcase}."
    end

    def initials_of(full_name)
      name, surname = full_name.split(/\s/)
      "#{initial_of(name)} #{initial_of(surname)}"
    end
  end
end
