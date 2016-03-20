require 'nikky/twitter'
require 'nikky/wordpress'

namespace :cache do
  desc "Populates API caches"
  task populate: :environment do
    Rails.logger.tagged('Cache') do
      Rails.cache.write('wordpress_posts', race_condition_ttl: 10, expires_in: 1.hour) do
        Nikky::Wordpress.new.recent_posts
      end
      Rails.logger.info("WordPress Cache Loaded")

      Rails.cache.write('tweets', race_condition_ttl: 10, expires_in: 1.hour) do
        Nikky::Twitter.new.recent_tweets
      end
      Rails.logger.info("Twitter Cache Loaded")
    end
  end
end
