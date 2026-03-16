require "test_helper"

class AgentsApiTest < ActionDispatch::IntegrationTest
  # ─── Agents CRUD ───────────────────────────────────────────────

  test "GET /api/agents returns all agents" do
    get api_agents_path
    assert_response :success
    data = JSON.parse(response.body)
    assert data["agents"].is_a?(Array)
    assert data["agents"].length > 0
  end

  test "GET /api/agents/:slug returns agent" do
    get api_agent_path("alex")
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "alex", data["agent"]["slug"]
  end

  test "GET /api/agents/:slug returns 404 for missing" do
    get api_agent_path("nonexistent")
    assert_response :not_found
  end

  test "POST /api/agents creates agent" do
    post api_agents_create_path, params: {
      agent: { name: "New Bot", slug: "new-bot", status: "active", agent_type: "content" }
    }, as: :json
    assert_response :created
    data = JSON.parse(response.body)
    assert_equal "new-bot", data["agent"]["slug"]
  end

  test "PATCH /api/agents/:slug updates agent" do
    patch api_agent_update_path("alex"), params: {
      agent: { description: "Updated description" }
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "Updated description", data["agent"]["description"]
  end

  # ─── Tasks CRUD ───────────────────────────────────────────────

  test "GET /api/agents/tasks returns tasks with pagination" do
    get api_agent_tasks_path
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("total_count")
    assert data.key?("tasks")
  end

  test "GET /api/agents/tasks filters by stage" do
    get api_agent_tasks_path, params: { stage: "new" }
    assert_response :success
    data = JSON.parse(response.body)
    data["tasks"].each { |t| assert_equal "new", t["stage"] }
  end

  test "POST /api/agents/tasks creates task" do
    post api_agent_tasks_create_path, params: {
      task: { title: "API created task", description: "Test", priority: 1 }
    }, as: :json
    assert_response :created
    data = JSON.parse(response.body)
    assert_equal "API created task", data["task"]["title"]
    assert data["task"]["slug"].present?
  end

  test "PATCH /api/agents/tasks/:id/transition queues task" do
    task = agent_tasks(:new_task)
    patch api_agent_task_transition_path(task.id), params: {
      transition: "queue"
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "queued", data["task"]["stage"]
  end

  test "PATCH /api/agents/tasks/:id/transition starts task" do
    task = agent_tasks(:queued_task)
    patch api_agent_task_transition_path(task.id), params: {
      transition: "start"
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "in_progress", data["task"]["stage"]
  end

  test "PATCH /api/agents/tasks/:id/transition completes task" do
    task = agent_tasks(:in_progress_task)
    patch api_agent_task_transition_path(task.id), params: {
      transition: "complete"
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "done", data["task"]["stage"]
  end

  test "PATCH /api/agents/tasks/:id/transition fails task" do
    task = agent_tasks(:in_progress_task)
    patch api_agent_task_transition_path(task.id), params: {
      transition: "fail"
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "failed", data["task"]["stage"]
  end

  test "PATCH /api/agents/tasks/:id/transition rejects invalid" do
    task = agent_tasks(:new_task)
    patch api_agent_task_transition_path(task.id), params: {
      transition: "bogus"
    }, as: :json
    assert_response :bad_request
  end

  test "PATCH /api/agents/tasks/:id/assign assigns agent" do
    task = agent_tasks(:new_task)
    patch api_agent_task_assign_path(task.id), params: {
      agent_slug: "mack"
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "mack", data["task"]["agent_slug"]
  end

  # ─── Usages API ───────────────────────────────────────────────

  test "POST /api/agents/usages upserts usage" do
    post api_agent_usages_create_path, params: {
      agent_slug: "alex",
      period_date: Date.today.to_s,
      model: "claude-sonnet-4-6",
      tokens_in: 5000,
      tokens_out: 1000,
      api_calls: 3,
      cost: 0.05
    }, as: :json
    assert_response :success
  end

  # ─── Activities API ──────────────────────────────────────────

  test "GET /api/agents/activities returns activities" do
    get api_agent_activities_path
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("activities")
  end
end
