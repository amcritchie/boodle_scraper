class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_destroy
  ]
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :set_api_post, only: [:api_show, :api_update, :api_destroy]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    @posts = Post.order(created_at: :desc)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to posts_path, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post was successfully deleted."
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_index
    posts = Post.order(created_at: :desc)
    posts = posts.where(stage: params[:stage]) if params[:stage].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min

    total_count = posts.count
    posts = posts.offset((page - 1) * per_page).limit(per_page)

    render json: {
      total_count: total_count,
      page: page,
      per_page: per_page,
      posts: posts.map { |p| post_json(p) }
    }
  end

  def api_show
    render json: { post: post_json(@post) }
  end

  def api_create
    @post = Post.new(api_post_params)

    if @post.save
      render json: { post: post_json(@post) }, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_update
    if @post.update(api_post_params)
      render json: { post: post_json(@post) }
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_destroy
    @post.destroy
    render json: { message: "Post deleted" }
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def set_api_post
    @post = Post.find_by(id: params[:id])
    render json: { error: "Post not found" }, status: :not_found unless @post
  end

  def post_params
    permitted = params.require(:post).permit(
      :title, :stage, :impressions, :likes, :content, :image_url,
      :image_proposals, :images_found_at, :image_selected_at,
      :approved_at, :posted_at
    )

    if permitted[:image_proposals].present? && permitted[:image_proposals].is_a?(String)
      permitted[:image_proposals] = JSON.parse(permitted[:image_proposals])
    end

    permitted
  end

  def api_post_params
    permitted = params.require(:post).permit(
      :title, :stage, :impressions, :likes, :content, :image_url,
      :images_found_at, :image_selected_at, :approved_at, :posted_at
    )

    permitted[:image_proposals] = params[:post][:image_proposals] if params[:post][:image_proposals].present?

    permitted
  end

  def post_json(post)
    {
      id: post.id,
      title: post.title,
      stage: post.stage,
      impressions: post.impressions,
      likes: post.likes,
      content: post.content,
      image_url: post.image_url,
      image_proposals: post.image_proposals,
      images_found_at: post.images_found_at,
      image_selected_at: post.image_selected_at,
      approved_at: post.approved_at,
      posted_at: post.posted_at,
      created_at: post.created_at,
      updated_at: post.updated_at
    }
  end
end
