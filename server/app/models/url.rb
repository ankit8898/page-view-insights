# frozen_string_literal: true
require 'validators/urls'
class Url < Sequel::Model

  one_to_many :page_views

  include Validator::Urls

  # Validates page view instance
  # name:      should be present
  # name:      should have valid url format
  def validate
    super
    errors.add(:name, 'cannot be empty')    if name.blank?
    errors.add(:name, 'is not a valid URL') unless valid_url?(name)
  end

end
