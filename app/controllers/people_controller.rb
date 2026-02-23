class PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_index, :api_show, :api_create, :api_update, :api_destroy
  ]
  before_action :set_person, only: [:edit, :update, :destroy]
  before_action :set_api_person, only: [:api_show, :api_update, :api_destroy]

  # ─── HTML Actions ───────────────────────────────────────────────

  def index
    @people = Person.order(last_name: :asc, first_name: :asc)
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to people_path, notice: "Person was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @person.update(person_params)
      redirect_to people_path, notice: "Person was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @person.destroy
    redirect_to people_path, notice: "Person was successfully deleted."
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_index
    people = Person.order(last_name: :asc, first_name: :asc)
    people = people.where(celebrity_type: params[:celebrity_type]) if params[:celebrity_type].present?
    people = people.where(player_slug: params[:player_slug]) if params[:player_slug].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min

    total_count = people.count
    people = people.offset((page - 1) * per_page).limit(per_page)

    render json: {
      total_count: total_count,
      page: page,
      per_page: per_page,
      people: people.map { |p| person_json(p) }
    }
  end

  def api_show
    render json: { person: person_json(@person) }
  end

  def api_create
    @person = Person.new(person_params)

    if @person.save
      render json: { person: person_json(@person) }, status: :created
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_update
    if @person.update(person_params)
      render json: { person: person_json(@person) }
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_destroy
    @person.destroy
    render json: { message: "Person deleted" }
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def set_api_person
    @person = Person.find_by(id: params[:id])
    render json: { error: "Person not found" }, status: :not_found unless @person
  end

  def person_params
    params.require(:person).permit(
      :first_name, :last_name, :slug, :celebrity_type, :player_slug,
      :birthday, :twitter_account, :twitter_hashtag, :last_image_used
    )
  end

  def person_json(person)
    {
      id: person.id,
      first_name: person.first_name,
      last_name: person.last_name,
      slug: person.slug,
      celebrity_type: person.celebrity_type,
      player_slug: person.player_slug,
      birthday: person.birthday,
      twitter_account: person.twitter_account,
      twitter_hashtag: person.twitter_hashtag,
      last_image_used: person.last_image_used,
      created_at: person.created_at,
      updated_at: person.updated_at
    }
  end
end
