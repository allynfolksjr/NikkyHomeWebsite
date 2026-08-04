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
      credentials = Rails.application.credentials.fetch(:wordpress)
      host = credentials.fetch(:host)
      username = credentials.fetch(:username)
      password = credentials.fetch(:password)

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
      Rails.logger.tagged('Wordpress', 'API') do
        Rails.logger.error{"Wordpress client failure: #{e.inspect}"}
      end
      []
    end

    private

    def convert_to_time(wordpress_time)
      wordpress_time.to_time.in_time_zone("Pacific Time (US & Canada)")
    end
  end
end
