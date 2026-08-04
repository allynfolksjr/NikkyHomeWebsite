require 'nikky/wordpress'
require_dependency Rails.root.join('lib/nikky/flickr').to_s

class HomeController < ApplicationController
  def index
    @wordpress_posts = Rails.cache.fetch('wordpress_posts', race_condition_ttl: 10, expires_in: 1.hour) do
      Nikky::Wordpress.new.recent_posts
    end

    @flickr_photos = Rails.cache.fetch('photos_landscape_metadata_v6', race_condition_ttl: 10, expires_in: 1.hour) do
      Nikky::Flickr.new.recent_photos
    end
  end
end
