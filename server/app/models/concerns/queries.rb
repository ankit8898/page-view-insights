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
      :url,
      Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited),
      Sequel.lit("count(*)").as(:visits)
    ]
  end

  #  SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited',
  #  count(*) AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE =  '2017-09-17')
  #  GROUP BY 'date_visited', 'url' ORDER BY 'visits' DESC LIMIT 1
  def self.top_urls_on_date_query(date)
    select(&SELECTED_COLUMNS_SCOPE)
    .where(CREATED_AT_SCOPE.call(date))
    .group(:date_visited, :url)
    .order(Sequel.desc(:visits))
    .limit(1)
  end

  # SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited', count(*)
  # AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-15'
  # AND '2017-09-16') GROUP BY 'date_visited', 'url'
  def self.top_urls_between_date_query(start_date, end_date)
    select(&SELECTED_COLUMNS_SCOPE)
    .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
    .group(:date_visited, :url)
  end
end
end
