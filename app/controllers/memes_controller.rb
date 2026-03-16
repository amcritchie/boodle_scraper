require "base64"

class MemesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_destroy
  ]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    @memes = Meme.unused_first
  end

  def show
    @meme = Meme.find(params[:id])
  end

  def new
    @meme = Meme.new
  end

  def create
    @meme = Meme.new(meme_html_params)
    if @meme.save
      redirect_to memes_path, notice: "Meme created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @meme = Meme.find(params[:id])
  end

  def update
    @meme = Meme.find(params[:id])
    if @meme.update(meme_html_params)
      redirect_to memes_path, notice: "Meme updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    meme = Meme.find(params[:id])
    meme.destroy
    redirect_to memes_path, notice: "Meme deleted."
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_index
    memes = Meme.unused_first
    memes = memes.by_feeling(params[:feeling])
    memes = memes.by_team(params[:team_slug])

    page     = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = memes.count
    memes = memes.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, memes: memes.map { |m| meme_json(m) } }
  end

  def api_show
    meme = Meme.find_by(id: params[:id])
    return render json: { error: "Meme not found" }, status: :not_found unless meme
    render json: { meme: meme_json(meme) }
  end

  def api_create
    meme = Meme.new(api_meme_params)
    if meme.save
      render json: { meme: meme_json(meme) }, status: :created
    else
      render json: { errors: meme.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_update
    meme = Meme.find_by(id: params[:id])
    return render json: { error: "Meme not found" }, status: :not_found unless meme
    if meme.update(api_meme_params)
      render json: { meme: meme_json(meme) }
    else
      render json: { errors: meme.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_destroy
    meme = Meme.find_by(id: params[:id])
    return render json: { error: "Meme not found" }, status: :not_found unless meme
    meme.destroy
    render json: { message: "Meme deleted" }
  end

  private

  def meme_html_params
    permitted = params.require(:meme).permit(
      :path, :feeling, :team_slug, :player_slug, :last_used_at, :rank, :feeling_array, :image_data
    )
    # Accept comma-separated string for feeling_array from HTML form
    if params[:meme][:feeling_array].is_a?(String)
      permitted[:feeling_array] = params[:meme][:feeling_array].split(",").map(&:strip).reject(&:blank?)
    end
    # Handle base64 image data (from file drop/select in browser)
    if permitted[:image_data].present? && permitted[:image_data].start_with?("data:image")
      saved_path = save_meme_image(permitted[:image_data])
      permitted[:path] = saved_path if saved_path.present?
    end
    permitted.except(:image_data)
  end

  def save_meme_image(data_url)
    match = data_url.match(/\Adata:image\/(\w+);base64,(.+)\z/m)
    return nil unless match

    ext = match[1].gsub("jpeg", "jpg")
    raw = Base64.decode64(match[2])
    filename = "meme-#{SecureRandom.hex(8)}.#{ext}"
    dir = Rails.root.join("public", "images", "memes")
    FileUtils.mkdir_p(dir)
    File.binwrite(dir.join(filename), raw)
    "/images/memes/#{filename}"
  rescue StandardError => e
    Rails.logger.error("[Memes] save_meme_image failed: #{e.message}")
    nil
  end

  def api_meme_params
    permitted = params.require(:meme).permit(
      :path, :feeling, :team_slug, :player_slug, :last_used_at, :rank, feeling_array: []
    )
    # If feeling_array was sent as a flat value (not array), handle gracefully
    if params[:meme][:feeling_array].is_a?(String)
      permitted[:feeling_array] = params[:meme][:feeling_array].split(",").map(&:strip).reject(&:blank?)
    end
    permitted
  end

  def meme_json(meme)
    {
      id:           meme.id,
      path:         meme.path,
      feeling:      meme.feeling,
      feeling_array: meme.feeling_array,
      team_slug:    meme.team_slug,
      player_slug:  meme.player_slug,
      last_used_at: meme.last_used_at,
      rank:         meme.rank,
      created_at:   meme.created_at,
      updated_at:   meme.updated_at
    }
  end
end
