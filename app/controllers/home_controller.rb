require 'wordpress'

class HomeController < ApplicationController
  def index
    @wordpress_posts = Rails.cache.fetch('wordpress_posts', race_condition_ttl: 10, expires_in: 1.hour) do
      Wordpress.new.recent_posts
    end
  end
end
