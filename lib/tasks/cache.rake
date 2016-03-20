require 'nikky/twitter'
require 'nikky/wordpress'
require 'nikky/flickr'

namespace :cache do
  desc "Populates API caches"
  task populate: :environment do
    Rails.logger.tagged('Cache') do
      wp = Nikky::Wordpress.new.recent_posts
      Rails.cache.write('wordpress_posts', wp, race_condition_ttl: 10, expires_in: 1.hour)
      Rails.logger.info("WordPress Cache Loaded")

      twitter = Nikky::Twitter.new.recent_tweets
      Rails.cache.write('tweets', twitter, race_condition_ttl: 10, expires_in: 1.hour)
      Rails.logger.info("Twitter Cache Loaded")

      photos = Nikky::Flickr.new.recent_photos
      Rails.cache.write('photos', photos, race_condition_ttl: 10, expires_in: 1.hour)
      Rails.logger.info("Flickr Cache Loaded")
    end
  end
end
