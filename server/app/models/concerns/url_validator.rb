# frozen_string_literal: true
module UrlValidator
  #Utility class for url validation

  # Checks if the url is valid
  def valid_url?(url)
    url.include?('http://') || url.include?('https://') || url.include?('www.')
  end
end
