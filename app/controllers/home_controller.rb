require 'nikky/wordpress'
require 'nikky/flickr'

class HomeController < ApplicationController
  def index
    @wordpress_posts = Rails.cache.fetch('wordpress_posts', race_condition_ttl: 10, expires_in: 1.hour) do
      Nikky::Wordpress.new.recent_posts
    end

    @flickr_photos = Rails.cache.fetch('photos', race_condition_ttl: 10, expires_in: 1.hour) do
      Nikky::Flickr.new.recent_photos
    end
  end
end
