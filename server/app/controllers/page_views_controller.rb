class PageViewsController < ApplicationController

  include PageViewParamsValidator
  # GET
  # Returns top urls for a particular date /top_urls?date=2017-09-14
  # Returns top urls for a date range /top_urls?start=2017-09-13&end=2017-09-14
  def top_urls
    if valid_params?(top_urls_params)
      render json: PageView.top_urls(top_urls_params),
        each_serializer: PageView::TopUrlsSerializer
    else
      render json: { message: invalid_params_message }
    end
  end

  # GET /dates
  def dates
    render json: PageView.dates,
      each_serializer: PageView::DatesSerializer
  end

  # GET /dates_range
  def dates_range
    render json: PageView.dates_ranges,
      each_serializer: PageView::DatesRangeSerializer
  end

  # GET /top_referrers
  def top_referrers
    if valid_params?(top_urls_params)
      render json: PageView.top_referrers(top_referrer_params),
        serializer: PageView::TopReferrerSerializer
    else
      render json: { message: invalid_params_message }
    end
  end

  private

  def top_urls_params
    params.permit(:date, :start, :end)
  end
  alias :top_referrer_params :top_urls_params
end
