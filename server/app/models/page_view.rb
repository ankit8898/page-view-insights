# frozen_string_literal: true
require 'validators/url'

class PageView < Sequel::Model
  # Page view model holds information about page_views. Urls visited, referrer
  # to those urls
  include Validator::Url
  # Queries for PageView
  include Queries
  # To support the model with AMS
  include ActiveModel::Serialization

  # Validates page view instance
  # url:      should be present
  # url:      should have valid url format
  def validate
    super
    errors.add(:url, 'cannot be empty')    if url.blank?
    errors.add(:url, 'is not a valid URL') unless valid_url?(url)
  end

  # Callback to update the MD5 hash of the record
  def after_create
    super
    update(hash: md5_digest)
  end

  class << self

    # Get the top urls from our PageView table. Responsible for
    def top_urls(params)
      keys = params.keys.collect(&:to_sym)
      case keys
        when [:date]
          top_urls_on_date(params[:date])
        when [:start, :end], [:end, :start]
          top_urls_between_date(params[:start], params[:end])
        end
    end

    # Returns top urls on a particular date
    # Usage:
    # PageView.top_urls_on_date('2017-09-15')
    def top_urls_on_date(date)
      top_urls_on_date_query(date).all
    end


    # Returns top urls between a date range.
    # Usage:
    # PageView.top_urls_between_date_query('2017-09-15','2017-09-16')
    def top_urls_between_date(start_date, end_date)
      top_urls_between_date_query(start_date, end_date)
      .all
      .group_by { |pv| pv[:date_visited] }
      .collect do |_, grouped_by_date_visited|
        grouped_by_date_visited.first
      end
    end

    # All Distinct dates in table
    def dates
      select(Sequel.lit("date_trunc('day', created_at)::DATE")
      .as(:date_visited))
      .order(Sequel.desc(:date_visited))
      .distinct(:date_visited)
      .all
    end

    # Building a dummy range for last n days
    def dates_ranges
      (1..8).to_a.collect do |i|
        {
          start_date:  i.days.ago,
          end_date:    DateTime.now,
          num_of_days: i + 1
         }
      end
    end
  end

  private

  def md5_digest
    Digest::MD5.hexdigest(self.to_hash.to_s)
  end
end
