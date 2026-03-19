# app/services/ai_review_service.rb
require "net/http"
require "json"

class AiReviewService
  API_URL = "https://api-inference.huggingface.co/models/bigcode/starcoder"

  def initialize(code)
    @code = code
    @api_key = Rails.application.credentials.huggingface_api_key
  end

  def analyze
    return [] if @code.blank?

    response = send_request
    parse_response(response)
  rescue => e
    Rails.logger.error("HF AI Error: #{e.message}")
    []
  end

  private

  def send_request
    uri = URI(API_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = body.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end

  def body
    {
      inputs: build_prompt
    }
  end

  def build_prompt
    <<~PROMPT
      Review the following code and return issues in JSON format:
      [
        { "line": number, "issue": "...", "suggestion": "..." }
      ]

      Code:
      #{@code}
    PROMPT
  end

  def parse_response(response)
    # HuggingFace returns text, not clean JSON
    raw_text = response.first["generated_text"] rescue ""

    begin
      JSON.parse(raw_text)
    rescue
      # fallback if parsing fails
      [
        { line: 1, issue: "AI response not structured", suggestion: raw_text.truncate(200) }
      ]
    end
  end
end