module Nikky
  class Twitter
    class Tweet
      attr_accessor :text, :posted_at, :uri
      def initialize(text, posted_at, uri)
        @text = text
        @posted_at = posted_at
        @uri = uri
      end
    end

    def recent_tweets
      client = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']}
      end

      # We have to fetch 100 tweets because the count includes replies and rts
      # For instance, if user had 38 replies, 42rts, 100 would return a 20-length
      # array :|
      tweets = client.user_timeline(
        'allynfolksjr',
        count: 100,
        exclude_replies: true,
        include_rts: false
      )

      # Hacky Way to not include a blog post in the twitter timeline on the site
      tweets = tweets.delete_if{|t| t.source =~ /WordPress\.com/}

      tweets.map do |tweet|
        Tweet.new(tweet.full_text, tweet.created_at, tweet.uri)
      end

    rescue StandardError => e
      Rails.logger.tagged('Twitter', 'API') do
        Rails.logger.error{"Twitter Client Failure. #{e.inspect}"}
      end
      []
    end
  end
end
