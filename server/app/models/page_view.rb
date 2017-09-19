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
  # referrer: should be a valid url format
  def validate
    super
    errors.add(:url, 'cannot be empty')    if url.blank?
    errors.add(:url, 'is not a valid URL') unless valid_url?(url)

    # TODO: Need to handle when referrer is empty
    #errors.add(:referrer, 'is not a valid URL') unless referrer.blank? && valid_url?(referrer)
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

    # SELECT "url", date_trunc('day', created_at)::DATE AS "date_visited",
    # count(*) AS "visits" FROM "page_views" WHERE (date_trunc('day', created_at)::DATE =  '2017-09-19')
    # GROUP BY "date_visited", "url" ORDER BY "visits" DESC LIMIT 1
    def top_urls_on_date(date)
      top_urls_on_date_query(date).all
    end


    # SELECT "url", date_trunc('day', created_at)::DATE AS "date_visited",
    # count(*) AS "visits" FROM "page_views"
    # WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-14' AND '2017-09-18')
    # GROUP BY "date_visited", "url"
    def top_urls_between_date(start_date, end_date)
      top_urls_between_date_query(start_date, end_date)
      .all
      .group_by {|pv| pv[:date_visited] }
      .collect do |_, grouped_by_date_visited|
        grouped_by_date_visited.max { |item| item[:visits] }
      end
    end
  end

  private

  def md5_digest
    Digest::MD5.hexdigest(self.to_hash.to_s)
  end
end
