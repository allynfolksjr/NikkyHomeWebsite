require 'flickraw'

module Nikky
  class Flickr
    class Photo
      attr_accessor :url, :image_url, :taken_at, :width, :height, :title, :metadata
      def initialize(url, image_url, taken_at, width, height, title, metadata)
        @url = url
        @image_url = image_url
        @taken_at = taken_at
        @width = width
        @height = height
        @title = title
        @metadata = metadata
      end
    end

    def initialize
      FlickRaw.api_key = ENV['FLICKR_API_KEY']
      FlickRaw.shared_secret = ENV['FLICKR_SECRET']
    end

    def recent_photos
      nsid = get_nsid_for_username("allynfolksjr")
      unrefined_images = flickr.people.getPublicPhotos(user_id: nsid,
        per_page: 100,
        extras: 'date_taken,o_dims')

      unrefined_images.select { |image| image['o_width'].to_i > image['o_height'].to_i }.first(8).map do |image|
        begin
          info = flickr.photos.getInfo(photo_id: image['id'])
          exif = flickr.photos.getExif(photo_id: image['id'])['exif'] || []
        rescue StandardError => e
          Rails.logger.warn("Flickr photo detail failure. #{e.inspect}")
          info = {}
          exif = []
        end
        metadata = photo_metadata(info, exif)

        Photo.new(FlickRaw.url_photopage(image),
          FlickRaw.url_b(image),
          Time.parse(image["datetaken"]),
          image['o_width'],
          image['o_height'],
          info['title'].to_s.presence || image['title'],
          metadata)
      end

    rescue StandardError => e
      Rails.logger.tagged('Flickr', 'API') do
        Rails.logger.error{"Flickr Client Failure. #{e.inspect}"}
      end
      []
    end

    private

    def photo_metadata(info, exif)
      {
        camera: exif_value(exif, 'Model'),
        lens: exif_value(exif, 'LensModel', 'Lens'),
        aperture: exif_value(exif, 'FNumber', 'Aperture'),
        shutter_speed: exif_value(exif, 'ExposureTime', 'ShutterSpeed'),
        iso: exif_value(exif, 'ISO'),
        location: photo_location(info['location'])
      }
    rescue StandardError => e
      Rails.logger.warn("Flickr metadata failure. #{e.inspect}")
      {}
    end

    def exif_value(exif, *tags)
      entry = exif.find { |value| tags.include?(value['tag']) }
      entry && (entry['clean'] || entry['raw'])
    end

    def photo_location(location)
      return unless location

      %w[locality county region country].filter_map do |place|
        location[place].to_s.presence
      end.join(', ').presence
    end

    def get_nsid_for_username(username)
      flickr.people.findByUsername(username: 'allynfolksjr')["nsid"]
    end
  end
end
