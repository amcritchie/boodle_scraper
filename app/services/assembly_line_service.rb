class AssemblyLineService
  def run_assembly_line
    # 1. Advance existing posts through pipeline
    advance_posts

    # 2. Generate new posts
    generate_new_posts
  end

  def self.run
    new.run_assembly_line
  end

  private

  def advance_posts
    # Step: approved → posted (post to X)
    post = Post.where(stage: "approved").order(created_at: :asc).first
    if post
      post_to_x(post)
      return
    end

    # Step: images → approved (auto-approve)
    post = Post.where(stage: "images").order(created_at: :asc).first
    if post
      post.update!(stage: "approved", approved_at: Time.current)
      return
    end

    # Step: draft → images (search for images)
    post = Post.where(stage: "draft").order(created_at: :asc).first
    if post
      find_images_for_post(post)
      return
    end

    puts "No posts to advance"
  end

  def generate_new_posts
    posts_to_generate = Setting.find_by(key: "posts_to_generate")&.value.to_i || 4
    sources = Setting.find_by(key: "sources_enabled")&.value || "yahoo,espn"
    source_list = sources.split(",")

    posts_to_generate.times do
      source = source_list.sample
      case source
      when "yahoo"
        result = YahooTrendService.new.run
      when "espn"
        result = EspnTrendService.new.run
      else
        result = ContentGenerator.new.generate_post
      end

      # Create Post from result
      post = Post.create!(
        title: result.title,
        content: result.title,
        sport: result.try(:sport),
        stage: "draft"
      )
      puts "Created post ##{post.id} (#{source})"
    end
  end

  def find_images_for_post(post)
    # Simple version: advance to images stage
    # TODO: integrate image search API
    post.update!(stage: "images", images_found_at: Time.current)
  end

  def post_to_x(post)
    twitter = TwitterService.new
    result = twitter.post_tweet(post.content)
    tweet_id = result.dig("data", "id")
    post.update!(
      stage: "posted",
      posted_at: Time.current
    )
    puts "Posted tweet #{tweet_id}"
  end
end
