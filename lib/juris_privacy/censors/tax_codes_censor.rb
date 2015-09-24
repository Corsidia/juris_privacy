require_relative 'censor_utils'

module JurisPrivacy
  # TaxCodesCensor
  class TaxCodesCensor
    include CensorUtils

    def inspect(content)
      tax_codes = content.scan(tax_code_regex)

      censored_tax_codes = {}
      tax_codes.each do |tax_code|
        unique_censored_tax_code = uniquify_hash_key(censor_word(tax_code),
                                                     censored_tax_codes)
        censored_tax_codes[unique_censored_tax_code] = tax_code
      end
      censored_tax_codes
    end

    private

    def tax_code_regex
      # Positive lookahead assertion to verify presence of at least 2 digits
      /
        (?=.*\d{2,})
        [a-zA-Z0-9]{16}
      /x
    end
  end
end
