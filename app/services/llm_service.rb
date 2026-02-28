class LlmService
  require "httparty"
  require "json"

  # Model configurations
  MODELS = {
    "claude-sonnet" => {
      provider: "anthropic",
      model: "claude-sonnet-4-20250514"
    },
    "minimax-m2.1" => {
      provider: "minimax",
      model: "MiniMax-M2.1"
    },
    "grok-3" => {
      provider: "xai",
      model: "grok-3"
    }
  }

  def self.extract(model:, prompt:)
    new(model: model).extract(prompt)
  end

  def initialize(model:)
    @model = model
    @config = MODELS[model] || MODELS["claude-sonnet"]
  end

  def extract(prompt)
    case @config[:provider]
    when "anthropic"
      call_anthropic(prompt)
    when "minimax"
      call_minimax(prompt)
    when "xai"
      call_xai(prompt)
    else
      raise "Unknown provider: #{@config[:provider]}"
    end
  end

  private

  def call_anthropic(prompt)
    # Would need API key - placeholder for now
    raise "Anthropic API not configured"
  end

  def call_minimax(prompt)
    # Would need API key - placeholder for now  
    raise "MiniMax API not configured"
  end

  def call_xai(prompt)
    # Would need API key - placeholder for now
    raise "xAI API not configured"
  end
end
