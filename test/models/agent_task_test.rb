require "test_helper"

class AgentTaskTest < ActiveSupport::TestCase
  test "fixtures load" do
    assert_equal 5, AgentTask.count
  end

  test "title is required" do
    task = AgentTask.new
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "slug is auto-generated on create" do
    task = AgentTask.create!(title: "New test task")
    assert task.slug.present?
    assert task.slug.start_with?("new-test-task-")
  end

  test "slug must be unique" do
    AgentTask.create!(title: "First", slug: "unique-slug")
    dupe = AgentTask.new(title: "Second", slug: "unique-slug")
    assert_not dupe.valid?
  end

  test "default stage is new" do
    task = AgentTask.create!(title: "Fresh task")
    assert_equal "new", task.stage
  end

  test "default priority is 0 (Normal)" do
    task = AgentTask.create!(title: "Normal task")
    assert_equal 0, task.priority
    assert_equal "Normal", task.priority_label
  end

  test "priority labels" do
    assert_equal "Normal", AgentTask.new(priority: 0).priority_label
    assert_equal "High", AgentTask.new(priority: 1).priority_label
    assert_equal "Urgent", AgentTask.new(priority: 2).priority_label
  end

  test "queue! transitions to queued" do
    task = agent_tasks(:new_task)
    task.queue!
    assert_equal "queued", task.stage
    assert task.queued_at.present?
  end

  test "start! transitions to in_progress" do
    task = agent_tasks(:queued_task)
    task.start!
    assert_equal "in_progress", task.stage
    assert task.started_at.present?
  end

  test "complete! transitions to done" do
    task = agent_tasks(:in_progress_task)
    task.complete!({ summary: "All good" })
    assert_equal "done", task.stage
    assert task.completed_at.present?
    assert_equal "All good", task.result["summary"]
  end

  test "fail! transitions to failed with message" do
    task = agent_tasks(:in_progress_task)
    task.fail!("Something broke")
    assert_equal "failed", task.stage
    assert task.failed_at.present?
    assert_equal "Something broke", task.error_message
  end

  test "archive! transitions to archived" do
    task = agent_tasks(:done_task)
    task.archive!
    assert_equal "archived", task.stage
    assert task.archived_at.present?
  end

  test "assign_to! sets agent_slug" do
    task = agent_tasks(:new_task)
    task.assign_to!("mack")
    assert_equal "mack", task.agent_slug
  end

  test "scopes filter by stage" do
    assert AgentTask.by_stage("new").all? { |t| t.stage == "new" }
    assert AgentTask.active.all? { |t| t.stage == "in_progress" }
    assert AgentTask.completed.all? { |t| t.stage == "done" }
    assert AgentTask.failed.all? { |t| t.stage == "failed" }
  end

  test "unassigned scope" do
    unassigned = AgentTask.unassigned
    assert unassigned.all? { |t| t.agent_slug.nil? }
  end

  test "high_priority scope" do
    high = AgentTask.high_priority
    assert high.all? { |t| t.priority >= 1 }
  end

  test "belongs to agent via slug" do
    task = agent_tasks(:queued_task)
    assert_equal "mason", task.agent.slug
  end
end
