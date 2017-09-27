module Queries

  extend ActiveSupport::Concern

  included do
    # Created at Scope that converts to YYYY-MM-DD
    # SELECT ... date_trunc('day', created_at)::DATE = '2017-09-14')...
    CREATED_AT_SCOPE       = -> (date) do
      Sequel.lit("date_trunc('day', created_at)::DATE =  '#{date}'")
    end

    # Created at Range Scope that converts to YYYY-MM-DD
    # SELECT ... date_trunc('day', created_at)::DATE BETWEEN '2017-09-13'..'2017-09-14')...
    CREATED_AT_RANGE_SCOPE = -> (start_date, end_date) do
      Sequel.lit("date_trunc('day', created_at)::DATE BETWEEN '#{start_date}' AND '#{end_date}'")
    end

    # Selected Columns Scope
    SELECTED_COLUMNS_SCOPE = -> do
      [
        :url_id,
        Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited),
        Sequel.lit("count(*)").as(:visits)
      ]
    end

    #  SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited',
    #  count(*) AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE =  '2017-09-17')
    #  GROUP BY 'date_visited', 'url' ORDER BY 'visits' DESC LIMIT 1
    def self.top_urls_on_date_query(date)
      eager(:url)
      .select(&SELECTED_COLUMNS_SCOPE)
      .where(CREATED_AT_SCOPE.call(date))
      .group(:date_visited, :url_id)
      .order(Sequel.desc(:visits))
    end

    # SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited', count(*)
    # AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-15'
    # AND '2017-09-16') GROUP BY 'date_visited', 'url'
    def self.top_urls_between_date_query(start_date, end_date)
      eager(:url)
      select(&SELECTED_COLUMNS_SCOPE)
      .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
      .group(:date_visited, :url_id)
      .order(Sequel.desc(:visits))
    end

    # SELECT "url_id" FROM "page_views" WHERE (date_trunc('day', created_at)::DATE =  '2017-09-20')
    # GROUP BY "url_id" ORDER BY count(*) DESC LIMIT 10
    def self.top_ten_url_ids_on_date_query(date)
      eager(:url)
      .select(:url_id)
      .where(CREATED_AT_SCOPE.call(date))
      .group(:url_id)
      .order(Sequel.desc(Sequel.lit("count(*)")))
      .limit(10)
    end

    # SELECT url_id FROM page_views WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24'
    # AND '2017-09-26') GROUP BY url_id ORDER BY count(*) DESC LIMIT 10
    def self.top_ten_url_ids_between_date_query(start_date, end_date)
      eager(:url)
      .select(:url_id)
      .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
      .group(:url_id)
      .order(Sequel.desc(Sequel.lit("count(*)")))
      .limit(10)
    end

    # SELECT 'url_id', 'referrer_url_id', count(*) AS 'visits',
    # date_trunc('day', created_at)::DATE AS 'date_visited' FROM 'page_views'
    # WHERE (('url_id' IN (SELECT 'url_id' FROM 'page_views'
    # WHERE (date_trunc('day', created_at)::DATE =  '2017-09-24') GROUP BY
    # 'url_id' ORDER BY count(*) DESC LIMIT 10)) AND
    # (date_trunc('day', created_at)::DATE =  '2017-09-24')) GROUP BY 'url_id',
    # 'referrer_url_id', 'date_visited' ORDER BY 'visits' DESC
    def self.top_referrers_on_date_query(date)
      eager(:url,:referrer_url)
      .select(:url_id, :referrer_url_id, Sequel.lit("count(*)").as(:visits), Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited))
      .where(url_id: top_ten_url_ids_on_date_query(date))
      .where(CREATED_AT_SCOPE.call(date))
      .group(:url_id,:referrer_url_id, :date_visited).order(Sequel.desc(:visits))
    end

    # SELECT url_id, referrer_url_id, count(*) AS visits, date_trunc('day', created_at)::DATE AS date_visited FROM page_views
    # WHERE ((url_id IN (SELECT url_id FROM page_views WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24' AND '2017-09-26')
    # GROUP BY url_id ORDER BY count(*) DESC LIMIT 10)) AND (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24' AND '2017-09-26'))
    # GROUP BY url_id, referrer_url_id, date_visited ORDER BY visits DESC
    def self.top_referrers_between_date_query(start_date, end_date)
      eager(:url, :referrer_url)
      .select(:url_id, :referrer_url_id, Sequel.lit("count(*)").as(:visits), Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited))
      .where(url_id: top_ten_url_ids_between_date_query(start_date, end_date))
      .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
      .group(:url_id,:referrer_url_id, :date_visited).order(Sequel.desc(:visits))
    end

    # SELECT date_trunc('day', created_at)::DATE AS date_visited from page_views
    def self.dates_query
      select(Sequel.lit("date_trunc('day', created_at)::DATE")
             .as(:date_visited))
      .order(Sequel.desc(:date_visited))
      .distinct(:date_visited)
    end
  end
end
