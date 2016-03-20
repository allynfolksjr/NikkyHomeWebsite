require 'rubypress'
module Nikky
  class Wordpress
    class Post
      attr_accessor :title, :content, :posted_at, :url
      def initialize(title, content, posted_at, url)
        @title = title
        @content = content
        @posted_at = posted_at
        @url = url
      end
    end

    def initialize
      host = ENV['WORDPRESS_HOST'] || raise('WORDPRESS_HOST not specified')
      username = ENV['WORDPRESS_USERNAME'] || raise('WORDPRESS_USERNAME not specified')
      password = ENV['WORDPRESS_PASSWORD'] || raise('WORDPRESS_PASSWORD not specified')

      @client = Rubypress::Client.new(use_ssl: true,
        host: host,
        username: username,
        password: password
      )
    end

    def recent_posts
      posts = @client.getPosts(filter: {order: 'desc', post_type: 'post', post_status: 'publish'})
      posts.map do |post|
        Post.new(post["post_title"],
          post["post_content"],
          convert_to_time(post["post_date"]),
          post["guid"]
        )
      end
    rescue StandardError => e
      Rails.logger.tagged('WordPress', 'API') do
        Rails.logger.error{"WordPress Client Failure. #{e.inspect}"}
      end
      []
    end

    private

    def convert_to_time(wordpress_time)
      wordpress_time.to_time.in_time_zone("Pacific Time (US & Canada)")
    end
  end
end
