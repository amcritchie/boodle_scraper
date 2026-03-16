require "test_helper"

class NewsApiTest < ActionDispatch::IntegrationTest
  test "GET /api/news returns paginated news" do
    get api_news_path
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("total_count")
    assert data.key?("page")
    assert data.key?("per_page")
    assert data["news"].is_a?(Array)
  end

  test "GET /api/news filters by stage" do
    get api_news_path, params: { stage: "new" }
    assert_response :success
    data = JSON.parse(response.body)
    data["news"].each { |n| assert_equal "new", n["stage"] }
  end

  test "GET /api/news filters by content_type" do
    get api_news_path, params: { content_type: "x_reply" }
    assert_response :success
    data = JSON.parse(response.body)
    data["news"].each { |n| assert_equal "x_reply", n["content_type"] }
  end

  test "GET /api/news/:id returns single news" do
    item = news(:schefter_tweet)
    get api_news_show_path(item.id)
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal item.title, data["news"]["title"]
  end

  test "GET /api/news/:id returns 404 for missing" do
    get api_news_show_path(999999)
    assert_response :not_found
  end

  test "POST /api/news creates news" do
    post api_news_create_path, params: {
      news: {
        title: "Breaking news",
        url: "https://x.com/unique/new-one",
        author: "TestBot",
        content_type: "x_post"
      }
    }, as: :json
    assert_response :created
    data = JSON.parse(response.body)
    assert_equal "Breaking news", data["news"]["title"]
    assert_equal "new", data["news"]["stage"]
  end

  test "PATCH /api/news/:id updates news" do
    item = news(:schefter_tweet)
    patch api_news_update_path(item.id), params: {
      news: { title_short: "Updated Title" }
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "Updated Title", data["news"]["title_short"]
  end

  test "PATCH /api/news/:id/transition advances stage" do
    item = news(:schefter_tweet)
    patch api_news_transition_path(item.id), params: { transition: "review" }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "reviewed", data["news"]["stage"]
  end

  test "PATCH /api/news/:id/transition rejects invalid" do
    item = news(:schefter_tweet)
    patch api_news_transition_path(item.id), params: { transition: "bogus" }, as: :json
    assert_response :bad_request
  end

  test "DELETE /api/news/:id deletes news" do
    item = news(:schefter_tweet)
    delete api_news_destroy_path(item.id)
    assert_response :success
    assert_nil News.find_by(id: item.id)
  end

  test "PATCH /api/news/:id/rank reorders news" do
    item = news(:schefter_tweet)
    patch api_rank_news_path(item.id), params: { before_id: nil, after_id: nil }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert data["news"]["rank"].present?
  end

  test "GET /api/news/posting_schedule returns schedule" do
    get api_posting_schedule_path
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("x_post_next_ms")
    assert data.key?("x_reply_next_ms")
  end
end
