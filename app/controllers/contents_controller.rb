class ContentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_destroy,
    :api_transition, :api_rank
  ]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    contents = Content.order(Arel.sql("COALESCE(rank, 0) DESC, created_at DESC"))
    @contents_by_stage = Content::STAGES.index_with { |_| [] }
    contents.each { |c| @contents_by_stage[c.stage] << c if @contents_by_stage.key?(c.stage) }
  end

  def show
    @content = Content.find(params[:id])
  end

  def new
    @content = Content.new
  end

  def create
    @content = Content.new(content_html_params)
    if @content.save
      redirect_to contents_path, notice: "Content created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @content = Content.find(params[:id])
  end

  def update
    @content = Content.find(params[:id])
    if @content.update(content_html_params)
      redirect_to contents_path, notice: "Content updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    content = Content.find(params[:id])
    content.destroy
    redirect_to contents_path, notice: "Content deleted."
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_index
    contents = Content.order(Arel.sql("COALESCE(rank, 0) DESC, created_at DESC"))
    contents = contents.where(stage: params[:stage]) if params[:stage].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = contents.count
    contents = contents.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, contents: contents.map { |c| content_json(c) } }
  end

  def api_show
    content = Content.find_by(id: params[:id])
    return render json: { error: "Content not found" }, status: :not_found unless content
    render json: { content: content_json(content) }
  end

  def api_create
    content = Content.new(api_content_params)
    if content.save
      render json: { content: content_json(content) }, status: :created
    else
      render json: { errors: content.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_update
    content = Content.find_by(id: params[:id])
    return render json: { error: "Content not found" }, status: :not_found unless content
    if content.update(api_content_params)
      render json: { content: content_json(content) }
    else
      render json: { errors: content.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_destroy
    content = Content.find_by(id: params[:id])
    return render json: { error: "Content not found" }, status: :not_found unless content
    content.destroy
    render json: { message: "Content deleted" }
  end

  def api_transition
    content = Content.find_by(id: params[:id])
    return render json: { error: "Content not found" }, status: :not_found unless content

    case params[:transition]
    when "refine"
      content.refine!
    when "video_create"
      content.video_create!
    when "edit"
      content.edit!
    when "queue"
      content.queue!
    when "post"
      content.post!
    else
      return render json: { error: "Invalid transition. Must be one of: refine, video_create, edit, queue, post" }, status: :bad_request
    end

    # Auto-assign rank: place at top of new stage (max_rank + 100)
    new_stage = content.stage
    max_rank = Content.where(stage: new_stage).where.not(id: content.id).maximum(:rank) || 0
    content.update!(rank: ((max_rank / 100.0).ceil + 1) * 100)

    render json: { content: content_json(content) }
  end

  def api_rank
    content = Content.find_by(id: params[:id])
    return render json: { error: "Content not found" }, status: :not_found unless content

    new_rank = if params[:before_id].present? && params[:after_id].present?
      before_item = Content.find_by(id: params[:before_id])
      after_item  = Content.find_by(id: params[:after_id])
      return render json: { error: "before/after items not found" }, status: :bad_request unless before_item && after_item
      ((before_item.rank.to_i + after_item.rank.to_i) / 2.0).round
    elsif params[:before_id].present?
      max_rank = Content.where(stage: content.stage).where.not(id: content.id).maximum(:rank) || 0
      max_rank + 100
    elsif params[:after_id].present?
      min_rank = Content.where(stage: content.stage).where.not(id: content.id).minimum(:rank) || 100
      [min_rank - 100, 0].max
    else
      100
    end

    if content.update(rank: new_rank)
      render json: { content: content_json(content) }
    else
      render json: { errors: content.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def content_html_params
    params.require(:content).permit(:prompt, :caption, :script, :video_url, :stage, :rank)
  end

  def api_content_params
    permitted = params.require(:content).permit(:prompt, :caption, :script, :video_url, :stage, :rank)
    permitted[:prompts] = params[:content][:prompts] if params[:content][:prompts].present?
    permitted[:video_parts] = params[:content][:video_parts] if params[:content][:video_parts].present?
    permitted[:video_choice] = params[:content][:video_choice] if params[:content][:video_choice].present?
    permitted
  end

  def content_json(content)
    {
      id: content.id,
      prompt: content.prompt,
      caption: content.caption,
      script: content.script,
      prompts: content.prompts,
      video_parts: content.video_parts,
      video_choice: content.video_choice,
      video_url: content.video_url,
      stage: content.stage,
      rank: content.rank,
      created_at: content.created_at,
      updated_at: content.updated_at
    }
  end
end
