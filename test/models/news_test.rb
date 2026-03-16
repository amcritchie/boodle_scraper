require "test_helper"

class NewsTest < ActiveSupport::TestCase
  test "fixtures load" do
    assert News.count > 0
  end

  test "title is required" do
    news = News.new(url: "https://example.com/unique")
    assert_not news.valid?
    assert_includes news.errors[:title], "can't be blank"
  end

  test "url uniqueness scoped to content_type on create" do
    existing = news(:schefter_tweet)
    dupe = News.new(
      title: "Duplicate",
      url: existing.url,
      content_type: existing.content_type
    )
    assert_not dupe.valid?
  end

  test "same url allowed for different content_type" do
    existing = news(:schefter_tweet)
    reply = News.new(
      title: "Reply version",
      url: existing.url,
      content_type: "x_reply"
    )
    assert reply.valid?
  end

  test "stage transitions" do
    item = news(:schefter_tweet)
    assert_equal "new", item.stage

    item.review!
    assert_equal "reviewed", item.stage

    item.write_content!
    assert_equal "content", item.stage

    item.edit!
    assert_equal "edited", item.stage

    item.queue!
    assert_equal "queued", item.stage

    item.post!
    assert_equal "posted", item.stage

    item.archive!
    assert_equal "archived", item.stage
  end

  test "posted_to_x? checks x_post fields" do
    posted = news(:posted_news)
    assert posted.posted_to_x?

    fresh = news(:schefter_tweet)
    assert_not fresh.posted_to_x?
  end

  test "by_stage scope" do
    new_items = News.by_stage("new")
    assert new_items.all? { |n| n.stage == "new" }
  end

  test "active scope excludes archived" do
    assert News.active.none? { |n| n.stage == "archived" }
  end

  test "STAGES and BOARD_STAGES constants" do
    assert_equal %w[new reviewed content edited queued posted], News::STAGES
    assert_includes News::BOARD_STAGES, "archived"
  end

  test "default stage is new" do
    item = News.create!(title: "Fresh news", url: "https://unique.com/fresh")
    assert_equal "new", item.stage
  end

  test "default content_type is x_post" do
    item = News.create!(title: "Default type", url: "https://unique.com/default")
    assert_equal "x_post", item.content_type
  end
end
