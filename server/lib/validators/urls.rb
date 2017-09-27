# frozen_string_literal: true
module Validator
  module Urls
    #Utility class for url validation

    # Checks if the url is valid
    def valid_url?(url)
      return if url.blank?
      url.include?('http://') || url.include?('https://') || url.include?('www.')
    end
  end
end
