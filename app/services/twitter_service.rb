class TwitterService
  TWEET_URL = "https://api.twitter.com/2/tweets".freeze
  MEDIA_UPLOAD_URL = "https://upload.twitter.com/1.1/media/upload.json".freeze

  def initialize
    @api_key = ENV.fetch("X_API_KEY")
    @api_secret = ENV.fetch("X_API_SECRET")
    @access_token = ENV.fetch("X_ACCESS_TOKEN")
    @access_token_secret = ENV.fetch("X_ACCESS_TOKEN_SECRET")
  end

  def post_tweet(text, media_url = nil)
    payload = { text: text }

    if media_url
      media_id = upload_media(media_url)
      payload[:media] = { media_ids: [media_id] } if media_id
    end

    response = HTTParty.post(
      TWEET_URL,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => oauth_header("POST", TWEET_URL)
      },
      body: payload.to_json
    )

    parsed = response.parsed_response
    unless response.success?
      raise "Twitter API error (#{response.code}): #{parsed}"
    end

    parsed
  end

  private

  def upload_media(media_url)
    image_data = HTTParty.get(media_url).body
    base64_data = Base64.strict_encode64(image_data)

    response = HTTParty.post(
      MEDIA_UPLOAD_URL,
      headers: {
        "Authorization" => oauth_header("POST", MEDIA_UPLOAD_URL)
      },
      body: { media_data: base64_data }
    )

    return nil unless response.success?

    response.parsed_response["media_id_string"]
  end

  def oauth_header(method, url, params = {})
    oauth_params = {
      oauth_consumer_key: @api_key,
      oauth_nonce: SecureRandom.hex,
      oauth_signature_method: "HMAC-SHA1",
      oauth_timestamp: Time.now.to_i.to_s,
      oauth_token: @access_token,
      oauth_version: "1.0"
    }

    all_params = oauth_params.merge(params)
    base_string = signature_base_string(method, url, all_params)
    signing_key = "#{CGI.escape(@api_secret)}&#{CGI.escape(@access_token_secret)}"
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("sha1", signing_key, base_string))

    oauth_params[:oauth_signature] = signature

    "OAuth " + oauth_params.map { |k, v| "#{k}=\"#{CGI.escape(v.to_s)}\"" }.join(", ")
  end

  def signature_base_string(method, url, params)
    sorted = params.sort.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
    "#{method.upcase}&#{CGI.escape(url)}&#{CGI.escape(sorted)}"
  end
end
