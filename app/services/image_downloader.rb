class ImageDownloader
  require "net/http"
  require "uri"
  require "open-uri"
  require "json"

  def self.download_for(name:, uploads_dir: "uploads")
    new(name: name, uploads_dir: uploads_dir).download
  end

  def initialize(name:, uploads_dir:)
    @name = name
    @uploads_dir = uploads_dir
  end

  def download
    return nil if @name.blank?

    image_url = find_image_url
    return nil unless image_url

    save_image(image_url)
  rescue => e
    Rails.logger.error "ImageDownloader error: #{e.message}"
    nil
  end

  private

  def find_image_url
    # Use Brave Search to find an image
    query = "#{@name} photo headshot"
    
    # Try to get image from search results
    uri = URI.parse("https://search.brave.com/resolver?q=#{URI.encode_www_form_component(query)}&source=web")
    
    # Alternative: use Google's image search via serper
    # For now, return nil - actual implementation would need proper image search API
    nil
  end

  def save_image(url)
    return nil if url.blank?

    filename = "#{slugify(@name)}.jpg"
    filepath = File.join(@uploads_dir, filename)

    begin
      uri = URI.parse(url)
      uri.open do |io|
        File.open(filepath, "wb") { |f| f.write(io.read) }
      end
      filepath
    rescue => e
      Rails.logger.error "Failed to download image: #{e.message}"
      nil
    end
  end

  def slugify(text)
    text.downcase.gsub(/[^a-z0-9]/, "-").gsub(/-+/, "-").strip
  end
end
