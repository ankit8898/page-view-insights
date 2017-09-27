# frozen_string_literal: true
class ReferrerUrl < Sequel::Model

  one_to_many :page_views

end
