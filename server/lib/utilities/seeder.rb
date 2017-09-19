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
    'http://opensource.org'
  ]

  # Url's which are Referrer to url's visited
  REFERRER_URLS =
  [
    'http://apple.com',
    'https://apple.com',
    'https://www.apple.com',
    'http://developer.apple.com',
    nil #nil to simulate a no referrer
  ]

  def initialize(num_of_rows, days)
    @num_of_rows = num_of_rows
    @days        = days
  end


  def seed
    @days.times do |day|
      created_at = DateTime.now - day
      batch = batch_of_rows(created_at)
      Parallel.each(batch, in_processes: 3) do |row_hsh|
        PageView.new(row_hsh).save
      end
    end

  end

  # Creating a batch of number of rows / number of days worth of data
  def batch_of_rows(created_at)
    n_times = @num_of_rows/@days
    n_times.times.collect do
      {
        url:        URLS.shuffle[rand(5)],
        referrer:   REFERRER_URLS.shuffle[rand(4)],
        created_at: created_at
      }
    end
  end


end
