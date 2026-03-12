class NewsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_destroy,
    :api_transition, :api_select_image
  ]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    news = News.recent
    @news_by_stage = News::BOARD_STAGES.index_with { |_| [] }
    news.each { |n| @news_by_stage[n.stage] << n if @news_by_stage.key?(n.stage) }
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
    news = News.recent
    news = news.by_stage(params[:stage]) if params[:stage].present?

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
    when "post"
      news.post!
    when "archive"
      news.archive!
    else
      return render json: { error: "Invalid transition. Must be one of: review, write_content, edit, post, archive" }, status: :bad_request
    end

    render json: { news: news_json(news) }
  end

  def api_select_image
    news = News.find_by(id: params[:id])
    return render json: { error: "News not found" }, status: :not_found unless news
    return render json: { error: "image_url is required" }, status: :bad_request if params[:image_url].blank?

    news.update!(selected_image: params[:image_url])
    render json: { news: news_json(news) }
  end

  private

  def news_html_params
    params.require(:news).permit(
      :title, :title_short, :url, :author, :published_at, :stage,
      :primary_person, :primary_person_slug, :primary_team, :primary_team_slug,
      :summary, :opinion, :selected_image, :x_post_id, :x_post_url
    )
  end

  def api_news_params
    permitted = params.require(:news).permit(
      :title, :title_short, :url, :author, :published_at, :stage,
      :primary_person, :primary_person_slug, :primary_team, :primary_team_slug,
      :summary, :opinion, :selected_image, :x_post_id, :x_post_url,
      :feeling, :feeling_emoji, :what_happened
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
      post_body: news.post_body, image_options: news.image_options,
      selected_image: news.selected_image,
      x_post_id: news.x_post_id, x_post_url: news.x_post_url,
      created_at: news.created_at, updated_at: news.updated_at
    }
  end
end
