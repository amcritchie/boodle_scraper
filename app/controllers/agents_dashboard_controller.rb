require 'open3'

class AgentsDashboardController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [
    :api_dashboard,
    :api_agents_index, :api_agents_show, :api_agents_create, :api_agents_update, :api_agents_destroy,
    :api_tasks_index, :api_tasks_show, :api_tasks_create, :api_tasks_update, :api_tasks_destroy,
    :api_tasks_assign, :api_tasks_transition,
    :api_skills_index, :api_skills_show, :api_skills_create, :api_skills_destroy,
    :api_skill_assignments_create, :api_skill_assignments_destroy,
    :api_activities_index, :api_activities_create,
    :api_usages_index, :api_usages_create,
    :api_push,
    :api_agent_set_model
  ]

  # ─── HTML Actions ───────────────────────────────────────────────

  def dashboard
    @agents = Agent.all.order(:name)
    @task_counts = AgentTask.group(:stage).count
    @recent_activities = AgentActivity.recent.limit(15)
    @unassigned_count = AgentTask.unassigned.pending.count
  end

  def agents_index
    @agents = Agent.all.order(:name)
  end

  def agents_show
    @agent = Agent.find_by!(slug: params[:slug])
    @tasks = @agent.agent_tasks.order(created_at: :desc).limit(10)
    @activities = @agent.agent_activities.recent.limit(10)
    @skills = @agent.agent_skills
    @usage_summary = @agent.agent_usages.recent.limit(7)
  end

  def agents_new
    @agent = Agent.new
  end

  def agents_create
    @agent = Agent.new(agent_html_params)
    if @agent.save
      redirect_to agents_dashboard_list_path, notice: "Agent created."
    else
      render :agents_new, status: :unprocessable_entity
    end
  end

  def agents_edit
    @agent = Agent.find_by!(slug: params[:slug])
  end

  def agents_update
    @agent = Agent.find_by!(slug: params[:slug])
    if @agent.update(agent_html_params)
      redirect_to agents_dashboard_list_path, notice: "Agent updated."
    else
      render :agents_edit, status: :unprocessable_entity
    end
  end

  def agents_destroy
    agent = Agent.find_by!(slug: params[:slug])
    agent.destroy
    redirect_to agents_dashboard_list_path, notice: "Agent deleted."
  end

  def tasks_index
    tasks = AgentTask.order(priority: :desc, created_at: :desc)
    tasks = tasks.where(agent_slug: params[:agent]) if params[:agent].present?
    @agents = Agent.all.order(:name)
    @agents_by_slug = @agents.index_by(&:slug)

    @tasks_by_stage = %w[new queued in_progress done failed archived].index_with { |_| [] }
    tasks.each { |t| @tasks_by_stage[t.stage] << t if @tasks_by_stage.key?(t.stage) }
  end

  def tasks_show
    @task = AgentTask.find(params[:id])
  end

  def tasks_new
    @task = AgentTask.new
    @agents = Agent.all.order(:name)
  end

  def tasks_create
    @task = AgentTask.new(task_html_params)
    if @task.save
      redirect_to agents_dashboard_tasks_path, notice: "Task created."
    else
      @agents = Agent.all.order(:name)
      render :tasks_new, status: :unprocessable_entity
    end
  end

  def tasks_edit
    @task = AgentTask.find(params[:id])
    @agents = Agent.all.order(:name)
  end

  def tasks_update
    @task = AgentTask.find(params[:id])
    if @task.update(task_html_params)
      redirect_to agents_dashboard_tasks_path, notice: "Task updated."
    else
      @agents = Agent.all.order(:name)
      render :tasks_edit, status: :unprocessable_entity
    end
  end

  def tasks_destroy
    task = AgentTask.find(params[:id])
    task.destroy
    redirect_to agents_dashboard_tasks_path, notice: "Task deleted."
  end

  def activity_index
    @activities = AgentActivity.recent
    @activities = @activities.for_agent(params[:agent]) if params[:agent].present?
    @activities = @activities.by_type(params[:type]) if params[:type].present?
    @agents = Agent.all.order(:name)
  end

  def skills_index
    @skills = AgentSkill.all.order(:name)
  end

  def usage_index
    @agents = Agent.all.order(:name)
    @usages = AgentUsage.recent
    @usages = @usages.for_agent(params[:agent]) if params[:agent].present?
  end

  # ─── API Actions ────────────────────────────────────────────────

  def api_dashboard
    agents = Agent.all
    task_counts = AgentTask.group(:stage).count
    render json: {
      agents_count: agents.count,
      active_agents: agents.active.count,
      task_counts: task_counts,
      unassigned_tasks: AgentTask.unassigned.pending.count,
      recent_activities: AgentActivity.recent.limit(10).map { |a| activity_json(a) }
    }
  end

  # --- Agents API ---

  def api_agents_index
    agents = Agent.order(:name)
    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = agents.count
    agents = agents.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, agents: agents.map { |a| agent_json(a) } }
  end

  def api_agents_show
    agent = Agent.find_by(slug: params[:slug])
    return render json: { error: "Agent not found" }, status: :not_found unless agent
    render json: { agent: agent_json(agent) }
  end

  def api_agents_create
    agent = Agent.new(api_agent_params)
    if agent.save
      render json: { agent: agent_json(agent) }, status: :created
    else
      render json: { errors: agent.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_agents_update
    agent = Agent.find_by(slug: params[:slug])
    return render json: { error: "Agent not found" }, status: :not_found unless agent
    if agent.update(api_agent_params)
      render json: { agent: agent_json(agent) }
    else
      render json: { errors: agent.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_agents_destroy
    agent = Agent.find_by(slug: params[:slug])
    return render json: { error: "Agent not found" }, status: :not_found unless agent
    agent.destroy
    render json: { message: "Agent deleted" }
  end

  def api_agent_set_model
    agent = Agent.find_by(slug: params[:slug])
    return render json: { error: "Agent not found" }, status: :not_found unless agent

    model = params[:model].to_s.strip
    return render json: { error: "model is required" }, status: :bad_request if model.blank?

    # Update DB
    agent.update!(config: agent.config.merge("model" => model))

    # Update openclaw.json
    config_path = File.expand_path("~/.openclaw/openclaw.json")
    if File.exist?(config_path)
      begin
        oc_config = JSON.parse(File.read(config_path))
        agents_list = oc_config.dig("agents", "list") || []
        agent_entry = agents_list.find { |a| a["id"] == agent.slug }
        if agent_entry
          agent_entry["model"] = model
          File.write(config_path, JSON.pretty_generate(oc_config))
        end
      rescue => e
        Rails.logger.warn "Could not update openclaw.json: #{e.message}"
      end
    end

    render json: { agent: agent_json(agent), model: model, message: "Model updated to #{model}" }
  end

  # --- Tasks API ---

  def api_tasks_index
    tasks = AgentTask.order(created_at: :desc)
    tasks = tasks.by_stage(params[:stage]) if params[:stage].present?
    tasks = tasks.where(agent_slug: params[:agent_slug]) if params[:agent_slug].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = tasks.count
    tasks = tasks.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, tasks: tasks.map { |t| task_json(t) } }
  end

  def api_tasks_show
    task = AgentTask.find_by(id: params[:id])
    return render json: { error: "Task not found" }, status: :not_found unless task
    render json: { task: task_json(task) }
  end

  def api_tasks_create
    task = AgentTask.new(api_task_params)
    if task.save
      render json: { task: task_json(task) }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_tasks_update
    task = AgentTask.find_by(id: params[:id])
    return render json: { error: "Task not found" }, status: :not_found unless task
    if task.update(api_task_params)
      render json: { task: task_json(task) }
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_tasks_destroy
    task = AgentTask.find_by(id: params[:id])
    return render json: { error: "Task not found" }, status: :not_found unless task
    task.destroy
    render json: { message: "Task deleted" }
  end

  def api_tasks_assign
    task = AgentTask.find_by(id: params[:id])
    return render json: { error: "Task not found" }, status: :not_found unless task

    agent_slug_val = params[:agent_slug]
    if agent_slug_val.present?
      agent = Agent.find_by(slug: agent_slug_val)
      return render json: { error: "Agent not found" }, status: :not_found unless agent
    end

    task.assign_to!(agent_slug_val)
    render json: { task: task_json(task) }
  end

  def api_tasks_transition
    task = AgentTask.find_by(id: params[:id])
    return render json: { error: "Task not found" }, status: :not_found unless task

    case params[:transition]
    when "queue"
      task.queue!
    when "start"
      task.start!
    when "complete"
      task.complete!(params[:result] || {})
    when "fail"
      task.fail!(params[:error_message])
    when "archive"
      task.archive!
    else
      return render json: { error: "Invalid transition. Must be one of: queue, start, complete, fail, archive" }, status: :bad_request
    end

    # Log activity
    activity_type = case params[:transition]
                    when "complete" then "task_completed"
                    when "fail" then "task_failed"
                    else "task_started"
                    end
    AgentActivity.create!(
      agent_slug: task.agent_slug,
      activity_type: activity_type,
      description: "Task '#{task.title}' transitioned to #{task.stage}",
      task_slug: task.slug
    )

    render json: { task: task_json(task) }
  end

  # --- Skills API ---

  def api_skills_index
    skills = AgentSkill.order(:name)
    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = skills.count
    skills = skills.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, skills: skills.map { |s| skill_json(s) } }
  end

  def api_skills_show
    skill = AgentSkill.find_by(slug: params[:slug])
    return render json: { error: "Skill not found" }, status: :not_found unless skill
    render json: { skill: skill_json(skill) }
  end

  def api_skills_create
    skill = AgentSkill.new(api_skill_params)
    if skill.save
      render json: { skill: skill_json(skill) }, status: :created
    else
      render json: { errors: skill.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_skills_destroy
    skill = AgentSkill.find_by(slug: params[:slug])
    return render json: { error: "Skill not found" }, status: :not_found unless skill
    skill.destroy
    render json: { message: "Skill deleted" }
  end

  # --- Skill Assignments API ---

  def api_skill_assignments_create
    assignment = AgentSkillAssignment.new(
      agent_slug: params[:agent_slug],
      skill_slug: params[:skill_slug],
      proficiency: params[:proficiency] || 100
    )
    if assignment.save
      render json: { assignment: { id: assignment.id, agent_slug: assignment.agent_slug, skill_slug: assignment.skill_slug, proficiency: assignment.proficiency } }, status: :created
    else
      render json: { errors: assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def api_skill_assignments_destroy
    assignment = AgentSkillAssignment.find_by(id: params[:id])
    return render json: { error: "Assignment not found" }, status: :not_found unless assignment
    assignment.destroy
    render json: { message: "Skill assignment removed" }
  end

  # --- Activities API ---

  def api_activities_index
    activities = AgentActivity.recent
    activities = activities.for_agent(params[:agent_slug]) if params[:agent_slug].present?
    activities = activities.by_type(params[:activity_type]) if params[:activity_type].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = activities.count
    activities = activities.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, activities: activities.map { |a| activity_json(a) } }
  end

  def api_activities_create
    activity_params = params[:activity] || {}
    agent_slug_val  = activity_params[:agent_slug].presence
    activity_type_val = activity_params[:activity_type].presence

    unless agent_slug_val && activity_type_val
      return render json: { errors: ["agent_slug can't be blank", "activity_type can't be blank"].reject { |e|
        (e.include?("agent_slug") && agent_slug_val) || (e.include?("activity_type") && activity_type_val)
      } }, status: :unprocessable_entity
    end

    activity = AgentActivity.new(
      agent_slug:    agent_slug_val,
      activity_type: activity_type_val,
      description:   activity_params[:description],
      task_slug:     activity_params[:task_slug],
      metadata:      activity_params[:metadata] || {}
    )

    if activity.save
      render json: { activity: activity_json(activity) }, status: :created
    else
      render json: { errors: activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # --- Usages API ---

  def api_usages_index
    usages = AgentUsage.recent
    usages = usages.for_agent(params[:agent_slug]) if params[:agent_slug].present?

    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || 25).to_i, 100].min
    total_count = usages.count
    usages = usages.offset((page - 1) * per_page).limit(per_page)

    render json: { total_count: total_count, page: page, per_page: per_page, usages: usages.map { |u| usage_json(u) } }
  end

  def api_usages_create
    usage = AgentUsage.find_or_initialize_by(
      agent_slug: params[:agent_slug],
      period_date: params[:period_date]
    )
    usage.assign_attributes(api_usage_params)
    if usage.save
      render json: { usage: usage_json(usage) }, status: usage.previously_new_record? ? :created : :ok
    else
      render json: { errors: usage.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ─── Code Push ──────────────────────────────────────────────────

  # POST /api/agents/push
  # Fires sequential dev-loop cron runs for Mason, Alex, Mack.
  # Cron IDs are read from ENV (CRON_ID_MASON, CRON_ID_ALEX, CRON_ID_MACK)
  # with sensible defaults matching the current openclaw.json cron entries.
  PUSH_AGENTS = [
    { slug: "mason", cron_id: ENV.fetch("CRON_ID_MASON", "561325c4-70c9-4340-9042-363c92137007") },
    { slug: "alex",  cron_id: ENV.fetch("CRON_ID_ALEX",  nil) },
    { slug: "mack",  cron_id: ENV.fetch("CRON_ID_MACK",  nil) },
  ].freeze

  def api_push
    triggered = []
    errors    = []
    timeout_ms = 180_000 # 3 minutes per agent

    PUSH_AGENTS.each do |agent|
      next unless agent[:cron_id].present?

      cmd = "openclaw cron run #{agent[:cron_id]} --timeout #{timeout_ms}"
      Rails.logger.info "[CodePush] Running: #{cmd}"

      output, status = Open3.capture2e(cmd)
      if status.success?
        triggered << agent[:slug]
        Rails.logger.info "[CodePush] #{agent[:slug]} completed. Output: #{output.strip.first(200)}"
      else
        errors << { agent: agent[:slug], error: output.strip.first(300) }
        Rails.logger.warn "[CodePush] #{agent[:slug]} failed: #{output.strip.first(300)}"
      end
    end

    render json: { ok: errors.empty?, triggered: triggered, errors: errors }
  end

  private

  # ─── HTML Params ────────────────────────────────────────────────

  def agent_html_params
    permitted = params.require(:agent).permit(:name, :slug, :status, :description, :avatar_url, :agent_type, :title)
    if params[:agent][:config].present? && params[:agent][:config].is_a?(String)
      permitted[:config] = JSON.parse(params[:agent][:config]) rescue {}
    end
    permitted
  end

  def task_html_params
    permitted = params.require(:agent_task).permit(:title, :description, :stage, :priority, :agent_slug)
    if params[:agent_task][:required_skills].present? && params[:agent_task][:required_skills].is_a?(String)
      permitted[:required_skills] = JSON.parse(params[:agent_task][:required_skills]) rescue []
    end
    permitted
  end

  # ─── API Params ─────────────────────────────────────────────────

  def api_agent_params
    permitted = params.require(:agent).permit(:name, :slug, :status, :description, :avatar_url, :agent_type, :title, :last_active_at)
    permitted[:config] = params[:agent][:config] if params[:agent][:config].present?
    permitted[:metadata] = params[:agent][:metadata] if params[:agent][:metadata].present?
    permitted
  end

  def api_task_params
    permitted = params.require(:task).permit(:title, :slug, :description, :stage, :priority, :agent_slug, :error_message,
                                             :queued_at, :started_at, :completed_at, :failed_at)
    permitted[:required_skills] = params[:task][:required_skills] if params[:task][:required_skills].present?
    permitted[:result] = params[:task][:result] if params[:task][:result].present?
    permitted[:metadata] = params[:task][:metadata] if params[:task][:metadata].present?
    permitted
  end

  def api_skill_params
    params.require(:skill).permit(:name, :slug, :category, :description)
  end

  def api_usage_params
    params.permit(:period_type, :model, :tokens_in, :tokens_out, :api_calls, :cost, :tasks_completed, :tasks_failed)
  end

  # ─── JSON Serializers ──────────────────────────────────────────

  def agent_json(agent)
    {
      id: agent.id, name: agent.name, slug: agent.slug, status: agent.status, title: agent.title,
      description: agent.description, avatar_url: agent.avatar_url, agent_type: agent.agent_type,
      config: agent.config, metadata: agent.metadata, last_active_at: agent.last_active_at,
      created_at: agent.created_at, updated_at: agent.updated_at
    }
  end

  def task_json(task)
    {
      id: task.id, title: task.title, slug: task.slug, description: task.description,
      stage: task.stage, priority: task.priority, priority_label: task.priority_label,
      agent_slug: task.agent_slug, required_skills: task.required_skills,
      result: task.result, metadata: task.metadata,
      queued_at: task.queued_at, started_at: task.started_at, completed_at: task.completed_at, failed_at: task.failed_at,
      error_message: task.error_message, archived_at: task.archived_at, created_at: task.created_at, updated_at: task.updated_at
    }
  end

  def skill_json(skill)
    {
      id: skill.id, name: skill.name, slug: skill.slug, category: skill.category,
      description: skill.description, config: skill.config,
      created_at: skill.created_at, updated_at: skill.updated_at
    }
  end

  def activity_json(activity)
    {
      id: activity.id, agent_slug: activity.agent_slug, activity_type: activity.activity_type,
      description: activity.description, task_slug: activity.task_slug, metadata: activity.metadata,
      created_at: activity.created_at
    }
  end

  def usage_json(usage)
    {
      id: usage.id, agent_slug: usage.agent_slug, period_date: usage.period_date,
      period_type: usage.period_type, model: usage.model,
      tokens_in: usage.tokens_in, tokens_out: usage.tokens_out, total_tokens: usage.total_tokens,
      api_calls: usage.api_calls, cost: usage.cost.to_f,
      tasks_completed: usage.tasks_completed, tasks_failed: usage.tasks_failed,
      success_rate: usage.success_rate, metadata: usage.metadata,
      created_at: usage.created_at, updated_at: usage.updated_at
    }
  end
end
