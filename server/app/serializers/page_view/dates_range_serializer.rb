class PageView::DatesRangeSerializer < ActiveModel::Serializer

  def attributes(_options = {}, _reload = false)
    {
      start_date:          object[:start_date].strftime('%Y-%m-%d'),
      end_date:            object[:end_date].strftime('%Y-%m-%d'),
      display_num_of_days: "Last #{object[:num_of_days]} days"
    }
  end
end
