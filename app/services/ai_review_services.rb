# app/services/ai_review_service.rb
require "net/http"
require "json"

class AiReviewServices
    API_URL = "https://router.huggingface.co/models/bigcode/starcoder"

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
  Rails.logger.debug("HF Raw Response: #{response.inspect}")
  
  # Agar response error hash hai
  if response.is_a?(Hash) && response["error"]
    return [{ "line" => 1, "issue" => "API Error: #{response["error"]}", "suggestion" => "Check your API key or try again" }]
  end

  # Normal response
  raw_text = response.is_a?(Array) ? response.first&.dig("generated_text").to_s : ""

  begin
    # JSON part extract karo prompt ke baad
    json_match = raw_text.match(/\[.*\]/m)
    json_match ? JSON.parse(json_match[0]) : [{ "line" => 1, "issue" => "Could not parse AI response", "suggestion" => raw_text.truncate(200) }]
  rescue
    [{ "line" => 1, "issue" => "AI response not structured", "suggestion" => raw_text.truncate(200) }]
    end
  end
end