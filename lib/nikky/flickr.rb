require 'flickraw'

module Nikky
  class Flickr
    class Photo
      attr_accessor :url, :image_url, :taken_at
      def initialize(url, image_url, taken_at)
        @url = url
        @image_url = image_url
        @taken_at = taken_at
      end
    end

    def initialize
      FlickRaw.api_key = ENV['FLICKR_API_KEY']
      FlickRaw.shared_secret = ENV['FLICKR_SECRET']
    end

    def recent_photos
      nsid = get_nsid_for_username("allynfolksjr")
      unrefined_images = flickr.people.getPublicPhotos(user_id: nsid,
        per_page: 25,
        extras: 'date_taken')

      unrefined_images.map do |image|
        Photo.new( FlickRaw.url_photopage(image),
          FlickRaw.url_b(image),
          Time.parse(image["datetaken"]))
      end

    rescue StandardError => e
      Rails.logger.tagged('Flickr', 'API') do
        Rails.logger.error{"Flickr Client Failure. #{e.inspect}"}
      end
      []
    end

    private
    def get_nsid_for_username(username)
      flickr.people.findByUsername(username: 'allynfolksjr')["nsid"]
    end
  end
end
