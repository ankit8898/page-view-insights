class PageView::TopReferrerSerializer < ActiveModel::Serializer

  # Serializers acts as presenter layer for the Json response
  #
  # Top urls we are looking at a presentation of
  # {
  #  '2017-01-01' : [
  #     {
  #       'url': 'http://apple.com',
  #       'visits': 100,
  #       'referrers': [ { 'url': 'http://store.apple.com/us', 'visits': 10 } ]
  #     }
  #   ]
  # }
  def attributes(_options = {}, _reload = false)
    object
    .group_by { |pv| pv[:date_visited] }
    .collect.with_object({}) do |(date, page_views), hsh|
      grouped_by_url = page_views.group_by { |pv| pv.url.name }
      hsh[date.strftime('%Y-%m-%d')] = grouped_by_url.collect do |url, url_page_views|
        {
          url:       url,
          visits:    url_page_views.collect {|pv| pv[:visits]}.inject(:+),
          referrers: url_page_views.take(5).collect {|pv| {url: pv.referrer_url.name, visits: pv[:visits]} }
        }
      end.sort_by {|info| info[:visits]}.reverse
    end
  end

end
