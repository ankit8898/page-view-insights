class PageView < Sequel::Model

  include UrlValidator

  # Validates page view instance
  # url: should be present
  # url: should have valid format
  def validate
    super
    errors.add(:url, 'cannot be empty') if !url || url.empty?
    errors.add(:url, 'is not a valid URL') unless valid_url?(url) #url =~ /\Ahttps?:\/\//
    errors.add(:referrer, 'is not a valid URL') unless valid_url?(referrer)
  end


end
