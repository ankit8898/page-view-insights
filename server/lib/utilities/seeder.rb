# frozen_string_literal: true
class Seeder
  # A common utility class for seed data purpose.  This can be reused to seed initial
  # data as well as test.

  # Urls which are visited by user
  URLS =
  [
    'http://apple.com',
    'https://apple.com',
    'https://www.apple.com',
    'http://developer.apple.com',
    'http://en.wikipedia.org',
    'http://opensource.org',
    'http://www.realtor.com',
    'http://www.google.com',
    'http://www.facebook.com',
    'http://developer.facebook.com',
    'http://api.facebook.com',
    'http://twitter.com',
    'http://nytimes.com',
    'http://ruby.com',
    'http://gmail.com'
  ]

  # Url's which are Referrer to url's visited
  REFERRER_URLS =
  [
    'http://apple.com',
    'https://apple.com',
    'https://www.apple.com',
    'http://developer.apple.com',
    'http://developer.console.com',
    'http://playstation.com',
    'https://www.realtor.com/homemade',
    'https://www.realtor.com/realestateandhomes-search/Austin_TX',
    'https://abcnews.com',
    'https://www.os.org',
    'http://api.facebook.com/users',
    'http://object.net',
    nil #nil to simulate a no referrer
  ]

  def initialize(num_of_rows, days)
    @num_of_rows = num_of_rows
    @days        = days
  end


  def seed
    seed_urls
    seed_referrer_urls
    url_ids          = Url.pluck(:id)
    referrer_url_ids = ReferrerUrl.pluck(:id)
    @days.times do |day|
      created_at = DateTime.now - day
      batch      = batch_of_rows(created_at, url_ids, referrer_url_ids)      
      PageView.multi_insert(batch)
    end
  end

  def seed_urls
    URLS.each do |url|
      Url.create(name: url)
    end
  end

  def seed_referrer_urls
    REFERRER_URLS.each do |url|
      ReferrerUrl.create(name: url)
    end
  end

  # Creating a batch of number of rows / number of days worth of data
  def batch_of_rows(created_at, url_ids, referrer_ids)
    n_times             = @num_of_rows/@days
    n_times.times.collect do
      url_id          = url_ids.shuffle[rand(url_ids.count)]
      referrer_url_id = referrer_ids.shuffle[rand(referrer_ids.count)]
      {
        url_id:          url_id,
        referrer_url_id: referrer_url_id,
        created_at:      created_at
      }
    end
  end


end
