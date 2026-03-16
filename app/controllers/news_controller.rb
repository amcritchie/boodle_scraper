class NewsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_destroy,
    :api_transition, :api_select_image, :api_rank, :api_organize_ranks,
    :api_posting_schedule
  ]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    news = News.order(Arel.sql("COALESCE(rank, 0) DESC, created_at DESC"))
    @news_by_stage = News::BOARD_STAGES.index_with { |_| [] }
    news.each { |n| @news_by_stage[n.stage] << n if @news_by_stage.key?(n.stage) }

    # Preload meme lookup for any card that has a meme_id (all stages)
    @meme_lookup = {}
    if ActiveRecord::Base.connection.table_exists?("memes")
      meme_ids = news.map(&:meme_id).compact.uniq
      @meme_lookup = Meme.where(id: meme_ids).index_by(&:id) if meme_ids.any?
    end
  end

  def show
    @news = News.find(params[:id])
  end

  def archived
    @archived_news = News.archived.recent
  end

  def new
    @news = News.new
  end

  def create
    @news = News.new(news_html_params)
    if @news.save
      redirect_to news_index_path, notice: "News created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @news = News.find(params[:id])
  end

  def update
    @news = News.find(params[:id])
    if @news.update(news_html_params)
      redirect_to news_index_path, notice: "News updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    news = News.find(params[:id])
    news.destroy
    redirect_to news_index_path, notice: "News deleted."
  end

  def select_image
    @news = News.find(params[:id])
    if params[:image_url].blank?
      redirect_to news_path(@news), alert: "image_url is required"
    else
      @news.update!(selected_image: params[:image_url])
      redirect_to news_path(@news), notice: "Image selected."
    end
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_index
    news = News.order(Arel.sql("COALESCE(rank, 0) DESC, created_at DESC"))
    news = news.by_stage(params[:stage]) if params[:stage].present?
    news = news.where(url: params[:url]) if params[:url].present?
    news = news.where(content_type: params[:content_type]) if params[:content_type].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = news.count
    news = news.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, news: news.map { |n| news_json(n) } }
  end

  def api_show
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news
    render json: { news: news_json(news) }
  end

  def api_create
    news = News.new(api_news_params)
    if news.save
      render json: { news: news_json(news) }, status: :created
    else
      render json: { errors: news.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_update
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news
    if news.update(api_news_params)
      render json: { news: news_json(news) }
    else
      render json: { errors: news.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_destroy
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news
    news.destroy
    render json: { message: "News deleted" }
  end

  def api_transition
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news

    case params[:transition]
    when "review"
      news.review!
    when "write_content"
      news.write_content!
    when "edit"
      news.edit!
    when "queue"
      news.queue!
    when "post"
      news.post!
    when "archive"
      news.archive!
    else
      return render json: { error: "Invalid transition. Must be one of: review, write_content, edit, queue, post, archive" }, status: :bad_request
    end

    # Auto-assign rank: place at top of new stage (max_rank + 100)
    new_stage = news.stage
    max_rank = News.where(stage: new_stage).where.not(id: news.id).maximum(:rank) || 0
    news.update!(rank: ((max_rank / 100.0).ceil + 1) * 100)

    render json: { news: news_json(news) }
  end

  def api_select_image
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news
    return render json: { error: "image_url is required" }, status: :bad_request if params[:image_url].blank?

    news.update!(selected_image: params[:image_url])
    render json: { news: news_json(news) }
  end

  def api_rank
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news

    # DESC rank system: highest rank = top of column = highest priority
    # after_id  = card rendered ABOVE the drop target (higher rank)
    # before_id = card rendered BELOW the drop target (lower rank)
    new_rank = if params[:before_id].present? && params[:after_id].present?
      # Drop between two cards — midpoint
      before_item = News.find_by(id: params[:before_id])
      after_item  = News.find_by(id: params[:after_id])
      return render json: { error: "before/after items not found" }, status: :bad_request unless before_item && after_item
      ((before_item.rank.to_i + after_item.rank.to_i) / 2.0).round
    elsif params[:before_id].present?
      # before_id only = nothing above the drop = TOP of column; go above before_id
      max_rank = News.where(stage: news.stage).where.not(id: news.id).maximum(:rank) || 0
      max_rank + 100
    elsif params[:after_id].present?
      # after_id only = nothing below the drop = BOTTOM of column; go below after_id
      min_rank = News.where(stage: news.stage).where.not(id: news.id).minimum(:rank) || 100
      [min_rank - 100, 0].max
    else
      # Empty column
      100
    end

    if news.update(rank: new_rank)
      render json: { news: news_json(news) }
    else
      render json: { errors: news.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_posting_schedule
    now_ms  = (Time.now.to_f * 1000).to_i
    now_min = Time.now.min
    now_sec = Time.now.sec

    # x_reply: */10 cron — next 10-min boundary
    mins_to_reply  = (10 - (now_min % 10)) % 10
    mins_to_reply  = 10 if mins_to_reply == 0 && now_sec > 5
    x_reply_next   = now_ms + ((mins_to_reply * 60 - now_sec) * 1000)

    # x_post: */30 cron with ~5 min stagger — next 30-min boundary + 5 min
    mins_to_post   = (30 - (now_min % 30)) % 30
    mins_to_post   = 30 if mins_to_post == 0 && now_sec > 5
    x_post_next    = now_ms + ((mins_to_post * 60 - now_sec + 300) * 1000)

    render json: {
      x_post_next_ms:  x_post_next,
      x_reply_next_ms: x_reply_next,
      now_ms:          now_ms
    }
  end

  def api_organize_ranks
    stages = News::BOARD_STAGES - ["archived"]
    updated = 0

    stages.each do |stage|
      records = News.where(stage: stage).order(Arel.sql("COALESCE(rank, 0) DESC, created_at DESC"))
      records.each_with_index do |record, index|
        new_rank = (records.length - index) * 100
        record.update_columns(rank: new_rank) if record.rank != new_rank
        updated += 1
      end
    end

    render json: { message: "Ranks organized", records_updated: updated }
  end

  private

  def news_html_params
    params.require(:news).permit(
      :title, :title_short, :url, :author, :published_at, :stage,
      :primary_person, :primary_person_slug, :primary_team, :primary_team_slug,
      :summary, :opinion, :selected_image, :x_post_id, :x_post_url, :hashtag,
      :content_type, :meme_id, :discord_message_id, :video_path
    )
  end

  def api_news_params
    permitted = params.require(:news).permit(
      :title, :title_short, :url, :author, :published_at, :stage,
      :primary_person, :primary_person_slug, :primary_team, :primary_team_slug,
      :summary, :opinion, :selected_image, :x_post_id, :x_post_url,
      :feeling, :feeling_emoji, :what_happened, :rank, :hashtag,
      :content_type, :meme_id, :discord_message_id, :video_path
    )
    permitted[:image_options] = params[:news][:image_options] if params[:news][:image_options].present?
    permitted[:post_body] = params[:news][:post_body] if params[:news][:post_body].present?
    permitted
  end

  def news_json(news)
    {
      id: news.id, title: news.title, title_short: news.title_short,
      stage: news.stage, url: news.url, author: news.author,
      published_at: news.published_at,
      primary_person: news.primary_person, primary_person_slug: news.primary_person_slug,
      primary_team: news.primary_team, primary_team_slug: news.primary_team_slug,
      summary: news.summary, opinion: news.opinion,
      feeling: news.feeling, feeling_emoji: news.feeling_emoji, what_happened: news.what_happened,
      post_body: news.post_body, image_options: news.image_options,
      selected_image: news.selected_image,
      x_post_id: news.x_post_id, x_post_url: news.x_post_url,
      rank: news.rank, hashtag: news.hashtag,
      content_type: news.content_type, meme_id: news.meme_id,
      discord_message_id: news.discord_message_id,
      video_path: news.video_path,
      created_at: news.created_at, updated_at: news.updated_at
    }
  end
end
