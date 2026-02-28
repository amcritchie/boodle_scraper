class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :retry, :destroy]

  def index
    @tasks = Task.order(created_at: :desc).limit(100)
    @tasks_by_status = {
      pending: @tasks.where(status: "pending"),
      running: @tasks.where(status: "running"),
      completed: @tasks.where(status: "completed"),
      failed: @tasks.where(status: "failed")
    }
  end

  def show
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      render json: @task, status: :created
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def retry
    @task.update(status: "pending", error: nil)
    render json: @task
  end

  def destroy
    @task.destroy
    head :no_content
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:task_type, :status, :input_json, :output_json, :error, :started_at, :completed_at)
  end
end
