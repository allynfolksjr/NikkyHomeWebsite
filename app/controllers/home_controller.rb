require 'nikky/wordpress'
require 'nikky/twitter'

class HomeController < ApplicationController
  def index
    @wordpress_posts = Rails.cache.fetch('wordpress_posts', race_condition_ttl: 10, expires_in: 1.hour) do
      Nikky::Wordpress.new.recent_posts
    end

    @tweets = Rails.cache.fetch('tweets', race_condition_ttl: 10, expires_in: 1.hour) do
      Nikky::Twitter.new.recent_tweets
    end
  end
end
