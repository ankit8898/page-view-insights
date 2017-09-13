# frozen_string_literal: true
class PageView < Sequel::Model
  # Page view model holds information about page_views. Urls visited, referrer
  # to those urls

  include UrlValidator

  # Validates page view instance
  # url: should be present
  # url: should have valid url format
  # referrer: should be a valid url format
  def validate
    super
    errors.add(:url, 'cannot be empty') if url.blank?
    errors.add(:url, 'is not a valid URL') unless valid_url?(url) #url =~ /\Ahttps?:\/\//

    # TODO: Need to handle when referrer is empty
    #errors.add(:referrer, 'is not a valid URL') unless referrer.blank? && valid_url?(referrer)
  end

  # Callback to update the MD5 hash of the record
  def after_create
    super
    update(hash: md5_digest)
  end

  private
  def md5_digest
    Digest::MD5.hexdigest(self.to_hash.to_s)
  end
end
