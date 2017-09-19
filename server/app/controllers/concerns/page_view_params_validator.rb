module PageViewParamsValidator

  extend ActiveSupport::Concern

  included do

    def valid_params?(params)
      keys = params.keys.collect(&:to_sym)
      case keys
      when [:date]
        valid_date?(params[:date])
      when [:start, :end], [:end, :start]
        valid_date?(params[:start]) && valid_date?(params[:end])
      else
        false
      end
    end

    # Validates if date is in format of YYYY-MM-DD and is a valid date
    def valid_date?(date)
      begin
        Date.parse(date) && date.match?(/\d{4}\-\d{2}\-\d{2}/)
      rescue
        false
      end
    end

    def invalid_params_message
      "InValidParameters: For date range look up pass start and end. Eg: /top_urls?start=2017-09-13&end=2017-09-14. For a single day pass a date. Eg: /top_urls?date=2017-09-14"
    end
  end
end
