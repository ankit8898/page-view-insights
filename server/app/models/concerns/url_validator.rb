module UrlValidator

  def valid_url?(url)
    url.include?('http://') || url.include?('https://') || url.include?('www.')
  end
end
