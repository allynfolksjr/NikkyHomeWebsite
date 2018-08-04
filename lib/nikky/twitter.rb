module Nikky
  class Twitter
    class Tweet
      attr_accessor :text, :posted_at, :url
      def initialize(text, posted_at, url)
        @text = text
        @posted_at = posted_at
        @url = url
      end
    end

    def recent_tweets
      client = ::Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      end

      # We have to fetch 200 tweets because the count includes replies and rts
      # For instance, if user had 38 replies, 142rts, 200 would return a 20-length
      # array :|
      unrefined_tweets = client.user_timeline(
        'allynfolksjr',
        count: 200,
        exclude_replies: true,
        include_rts: false,
        tweet_mode: 'extended'
        )


      # Hacky Way to not include a blog post in the twitter timeline on the site
      # Additionally, we don't want to include a subtweet, tweet with link, or
      # tweet with images for ideological pureness
      unrefined_tweets = unrefined_tweets.delete_if do |t|
        t.media? ||
        t.entities? ||
        t.source =~ /WordPress\.com/
      end

      unrefined_tweets.map do |tweet|
        Tweet.new(tweet.attrs[:full_text], tweet.created_at, tweet.uri.to_s)
      end

    rescue StandardError => e
      Rails.logger.tagged('Twitter', 'API') do
        Rails.logger.error{"Twitter Client Failure. #{e.inspect}"}
      end
      []
    end
  end
end
