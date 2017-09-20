class PageView::DatesSerializer < ActiveModel::Serializer

  def attributes(_options = {}, _reload = false)
    { date: object[:date_visited].strftime('%Y-%m-%d') }
  end
end
