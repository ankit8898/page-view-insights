class PageView::TopUrlsSerializer < ActiveModel::Serializer

  # Serializers acts as presenter layer for the Json response
  #
  # Top urls we are looking at a presentation of
  # { '2017-01-01' : [ { 'url': 'http://apple.com', 'visits': 100 } ] }
  def attributes(_options = {}, _reload = false)
    {
      "#{object[:date_visited].strftime('%Y-%m-%d')}" => [
        { url:  object[:url], visits: object[:visits] }
      ]
    }
  end

end
