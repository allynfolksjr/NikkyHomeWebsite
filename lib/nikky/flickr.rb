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
      credentials = Rails.application.credentials.fetch(:flickr)
      FlickRaw.api_key = credentials.fetch(:api_key)
      FlickRaw.shared_secret = credentials.fetch(:secret)
    end

    def recent_photos
      nsid = get_nsid_for_username
      unrefined_images = flickr.people.getPublicPhotos(user_id: nsid,
        per_page: 100,
        extras: 'date_taken,o_dims')

      unrefined_images.select { |image| image['o_width'].to_i > image['o_height'].to_i }.first(8).map do |image|
        exif = photo_exif(image['id'])
        metadata = photo_metadata(exif)

        Photo.new(FlickRaw.url_photopage(image),
          FlickRaw.url_b(image),
          Time.parse(image["datetaken"]),
          image['o_width'],
          image['o_height'],
          image['title'].to_s.presence,
          metadata)
      end

    rescue StandardError => e
      Rails.logger.tagged('Flickr', 'API') do
        Rails.logger.error{"Flickr client failure: #{e.inspect}"}
      end
      []
    end

    private

    def photo_exif(photo_id)
      flickr.photos.getExif(photo_id: photo_id)['exif'] || []
    rescue StandardError => e
      Rails.logger.warn("Flickr getExif failure: #{e.inspect}")
      []
    end

    def photo_metadata(exif)
      {
        camera: exif_value(exif, 'Model'),
        focal_length: exif_value(exif, 'Focal Length', 'FocalLength'),
        aperture: format_aperture(exif_value(exif, 'Aperture', 'F-Number', 'FNumber')),
        shutter_speed: format_shutter_speed(exif_value(exif, 'Exposure', 'Exposure Time', 'ExposureTime', 'Shutter Speed')),
        iso: exif_value(exif, 'ISO Speed', 'ISO'),
        location: gps_location(exif)
      }
    rescue StandardError => e
      Rails.logger.warn("Flickr metadata failure: #{e.inspect}")
      {}
    end

    def exif_value(exif, *tags)
      normalized_tags = tags.map { |tag| tag.downcase.delete(' -_') }
      entry = exif.find do |value|
        [value['tag'], value['label']].compact.any? do |tag|
          normalized_tags.include?(tag.to_s.downcase.delete(' -_'))
        end
      end
      entry && (entry['clean'] || entry['raw'])
    end

    def format_aperture(value)
      value.to_s.sub(/\Af\/?/i, '').presence
    end

    def format_shutter_speed(value)
      text = value.to_s
      reciprocal = text.match(/\b1\/\d+(?:\.\d+)?\b/)&.to_s
      return reciprocal if reciprocal

      decimal = text.match(/\b0?\.\d+\b/)&.to_s.to_f
      decimal.positive? ? "1/#{(1 / decimal).round}" : nil
    end

    def gps_location(exif)
      latitude = exif_value(exif, 'Latitude', 'GPS Latitude')
      longitude = exif_value(exif, 'Longitude', 'GPS Longitude')
      return unless latitude.present? && longitude.present?

      "#{latitude}, #{longitude}"
    end

    def get_nsid_for_username
      flickr.people.findByUsername(username: 'allynfolksjr')["nsid"]
    end
  end
end
