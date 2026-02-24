class ArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_feedback, :api_destroy, :api_docs
  ]
  before_action :set_article, only: [:edit, :update, :destroy, :feedback]
  before_action :set_api_article, only: [:api_show, :api_update, :api_feedback, :api_destroy]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    @articles = Article.order(Arel.sql("reviewed_at ASC NULLS FIRST, created_at DESC"))
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to articles_path, notice: "Article was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to articles_path, notice: "Article was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def feedback
    field = params[:field]
    value = params[:value] == "true"

    allowed_fields = %w[article_good person_identified disposition_coherent]
    if allowed_fields.include?(field)
      @article.update(field => value, reviewed_at: Time.current)
    end

    redirect_to articles_path
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: "Article was successfully deleted."
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_docs
    render json: {
      name: "Articles API",
      version: "v1",
      base_url: "/api/articles",
      endpoints: [
        {
          method: "GET",
          path: "/api/articles",
          description: "List all articles. Supports filtering and pagination.",
          params: {
            page: { type: "integer", required: false, default: 1, description: "Page number" },
            per_page: { type: "integer", required: false, default: 25, max: 100, description: "Results per page" },
            reviewed: { type: "boolean", required: false, description: "Filter by reviewed status (true = has reviewed_at, false = not reviewed)" },
            main_person_slug: { type: "string", required: false, description: "Filter by main_person_slug" },
            source: { type: "string", required: false, description: "Filter by source" }
          },
          response: "{ total_count, page, per_page, articles: [...] }"
        },
        {
          method: "GET",
          path: "/api/articles/:id",
          description: "Get a single article by ID.",
          response: "{ article: { id, title, author, ... } }"
        },
        {
          method: "POST",
          path: "/api/articles",
          description: "Create a new article.",
          params: {
            article: {
              type: "object",
              required: true,
              fields: {
                title: { type: "string" },
                author: { type: "string" },
                published_at: { type: "date", format: "YYYY-MM-DD" },
                reviewed_at: { type: "datetime", format: "ISO 8601" },
                main_person_slug: { type: "string" },
                main_person_name: { type: "string" },
                names: { type: "json", description: "Array of name strings, e.g. [\"Name 1\", \"Name 2\"]" },
                disposition: { type: "text" },
                feedback: { type: "text" },
                article_good: { type: "boolean" },
                person_identified: { type: "boolean" },
                disposition_coherent: { type: "boolean" },
                source: { type: "string" },
                source_url: { type: "string" },
                source_data_json: { type: "json", description: "Arbitrary JSON payload from source" }
              }
            }
          },
          response: "{ article: { ... } }"
        },
        {
          method: "PATCH",
          path: "/api/articles/:id",
          description: "Update an existing article. Send only the fields you want to change.",
          params: {
            article: { type: "object", description: "Same fields as POST /api/articles" }
          },
          response: "{ article: { ... } }"
        },
        {
          method: "PATCH",
          path: "/api/articles/:id/feedback",
          description: "Quick feedback toggle for boolean fields. Automatically sets reviewed_at.",
          params: {
            field: { type: "string", required: true, enum: %w[article_good person_identified disposition_coherent], description: "The boolean field to set" },
            value: { type: "string", required: true, enum: %w[true false], description: "The value to set" }
          },
          response: "{ article: { ... } }"
        },
        {
          method: "DELETE",
          path: "/api/articles/:id",
          description: "Delete an article.",
          response: "{ message: 'Article deleted' }"
        }
      ]
    }
  end

  def api_index
    articles = Article.order(created_at: :desc)
    articles = articles.where.not(reviewed_at: nil) if params[:reviewed] == "true"
    articles = articles.where(reviewed_at: nil) if params[:reviewed] == "false"
    articles = articles.where(main_person_slug: params[:main_person_slug]) if params[:main_person_slug].present?
    articles = articles.where(source: params[:source]) if params[:source].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min

    total_count = articles.count
    articles = articles.offset((page - 1) * per_page).limit(per_page)

    render json: {
      total_count: total_count,
      page: page,
      per_page: per_page,
      articles: articles.map { |a| article_json(a) }
    }
  end

  def api_show
    render json: { article: article_json(@article) }
  end

  def api_create
    @article = Article.new(api_article_params)

    if @article.save
      render json: { article: article_json(@article) }, status: :created
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_update
    if @article.update(api_article_params)
      render json: { article: article_json(@article) }
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_feedback
    field = params[:field]
    value = params[:value] == "true"

    allowed_fields = %w[article_good person_identified disposition_coherent]
    unless allowed_fields.include?(field)
      render json: { error: "Invalid field. Must be one of: #{allowed_fields.join(', ')}" }, status: :bad_request
      return
    end

    @article.update(field => value, reviewed_at: Time.current)
    render json: { article: article_json(@article) }
  end

  def api_destroy
    @article.destroy
    render json: { message: "Article deleted" }
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def set_api_article
    @article = Article.find_by(id: params[:id])
    render json: { error: "Article not found" }, status: :not_found unless @article
  end

  def article_params
    permitted = params.require(:article).permit(
      :title, :author, :sport, :published_at, :reviewed_at,
      :main_person_slug, :main_person_name, :disposition,
      :article_good, :person_identified, :disposition_coherent,
      :feedback, :names, :source, :source_url, :source_data_json
    )

    if permitted[:names].present? && permitted[:names].is_a?(String)
      permitted[:names] = JSON.parse(permitted[:names])
    end

    if permitted[:source_data_json].present? && permitted[:source_data_json].is_a?(String)
      permitted[:source_data_json] = JSON.parse(permitted[:source_data_json])
    end

    permitted
  end

  def api_article_params
    permitted = params.require(:article).permit(
      :title, :author, :sport, :published_at, :reviewed_at,
      :main_person_slug, :main_person_name, :disposition,
      :article_good, :person_identified, :disposition_coherent,
      :feedback, :source, :source_url
    )

    permitted[:names] = params[:article][:names] if params[:article][:names].present?
    permitted[:source_data_json] = params[:article][:source_data_json] if params[:article][:source_data_json].present?

    permitted
  end

  def article_json(article)
    {
      id: article.id,
      title: article.title,
      author: article.author,
      sport: article.sport,
      published_at: article.published_at,
      reviewed_at: article.reviewed_at,
      main_person_slug: article.main_person_slug,
      main_person_name: article.main_person_name,
      names: article.names,
      disposition: article.disposition,
      feedback: article.feedback,
      article_good: article.article_good,
      person_identified: article.person_identified,
      disposition_coherent: article.disposition_coherent,
      source: article.source,
      source_url: article.source_url,
      source_data_json: article.source_data_json,
      created_at: article.created_at,
      updated_at: article.updated_at
    }
  end
end
