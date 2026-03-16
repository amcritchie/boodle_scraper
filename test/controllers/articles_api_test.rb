require "test_helper"

class ArticlesApiTest < ActionDispatch::IntegrationTest
  test "GET /api/articles returns paginated articles" do
    get api_articles_path
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("total_count")
    assert data.key?("page")
    assert data.key?("per_page")
    assert data["articles"].is_a?(Array)
  end

  test "GET /api/articles filters by reviewed" do
    get api_articles_path, params: { reviewed: "true" }
    assert_response :success
    data = JSON.parse(response.body)
    data["articles"].each { |a| assert a["reviewed_at"].present? }
  end

  test "GET /api/articles/:id returns article" do
    article = articles(:one)
    get api_article_show_path(article.id)
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal article.title, data["article"]["title"]
  end

  test "POST /api/articles creates article" do
    post api_articles_create_path, params: {
      article: {
        title: "New Article",
        sport: "nfl",
        source: "test"
      }
    }, as: :json
    assert_response :created
    data = JSON.parse(response.body)
    assert_equal "New Article", data["article"]["title"]
  end

  test "PATCH /api/articles/:id updates article" do
    article = articles(:one)
    patch api_article_update_path(article.id), params: {
      article: { title: "Updated" }
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "Updated", data["article"]["title"]
  end

  test "PATCH /api/articles/:id/feedback toggles boolean" do
    article = articles(:one)
    patch api_article_feedback_path(article.id), params: {
      field: "article_good", value: "true"
    }, as: :json
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal true, data["article"]["article_good"]
    assert data["article"]["reviewed_at"].present?
  end

  test "PATCH /api/articles/:id/feedback rejects invalid field" do
    article = articles(:one)
    patch api_article_feedback_path(article.id), params: {
      field: "invalid_field", value: "true"
    }, as: :json
    assert_response :bad_request
  end

  test "DELETE /api/articles/:id deletes article" do
    article = articles(:one)
    delete api_article_destroy_path(article.id)
    assert_response :success
    assert_nil Article.find_by(id: article.id)
  end

  test "GET /api/articles/docs returns docs" do
    get api_articles_docs_path
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "Articles API", data["name"]
  end
end
