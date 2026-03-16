require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "agent fixtures load" do
    assert_equal 4, Agent.count
  end

  test "slug is required" do
    agent = Agent.new(name: "Test")
    assert_not agent.valid?
    assert_includes agent.errors[:slug], "can't be blank"
  end

  test "name is required" do
    agent = Agent.new(slug: "test")
    assert_not agent.valid?
    assert_includes agent.errors[:name], "can't be blank"
  end

  test "slug must be unique" do
    Agent.create!(name: "Dupe", slug: "dupe-agent")
    dupe = Agent.new(name: "Dupe 2", slug: "dupe-agent")
    assert_not dupe.valid?
    assert_includes dupe.errors[:slug], "has already been taken"
  end

  test "active scope returns only active agents" do
    active = Agent.active
    assert active.all? { |a| a.status == "active" }
  end

  test "paused scope returns paused agents" do
    paused = Agent.paused
    assert_equal 1, paused.count
    assert_equal "turf-monster", paused.first.slug
  end

  test "has many tasks through slug" do
    alex = agents(:alex)
    assert_respond_to alex, :agent_tasks
  end

  test "has many skills through assignments" do
    mack = agents(:mack)
    assert_equal 2, mack.agent_skills.count
  end

  test "tasks_by_stage groups correctly" do
    alex = agents(:alex)
    stages = alex.tasks_by_stage
    assert stages.is_a?(Hash)
  end

  test "destroying agent nullifies task assignment" do
    mason = agents(:mason)
    task = mason.agent_tasks.first
    mason.destroy
    task.reload
    assert_nil task.agent_slug
  end
end
