# app/services/ai_review_service.rb
require "net/http"
require "json"

class AiReviewService
  API_URL = "https://router.huggingface.co/models/bigcode/starcoder"
  REQUEST_TIMEOUT = 20 # seconds

  Result = Struct.new(:issues, :summary, keyword_init: true)

  def initialize(code_file)
    @code_file = code_file
    @code = code_file.content.to_s
    @language = code_file.language.presence || "plaintext"
    @api_key = Rails.application.credentials.huggingface_api_key
  end

  # Returns a Result struct: { issues: [...], summary: "..." }
  def analyze
    return empty_result if @code.blank?
    return missing_key_result if @api_key.blank?

    response = send_request
    parse_response(response)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("HF AI Timeout: #{e.message}")
    error_result("AI service timed out", "Please try again in a moment")
  rescue StandardError => e
    Rails.logger.error("HF AI Error: #{e.class} - #{e.message}")
    error_result("Unexpected error occurred", "Check application logs for details")
  end

  private

  def send_request
    uri = URI(API_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = REQUEST_TIMEOUT
    http.read_timeout = REQUEST_TIMEOUT

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("HF AI HTTP Error: #{response.code} - #{response.body}")
      return { "error" => "HTTP #{response.code}: #{response.message}" }
    end

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
      inputs: build_prompt,
      parameters: {
        max_new_tokens: 900,
        temperature: 0.2,
        return_full_text: false
      }
    }
  end

  def build_prompt
    <<~PROMPT
      You are a senior #{@language} code reviewer. Review the code below for bugs, security issues, performance problems, and style violations.

      Respond with ONLY a single valid JSON object. No explanations, no markdown, no code fences, no text before or after.

      The JSON object must have exactly this shape:
      {
        "summary": "one or two sentence overall verdict on code quality",
        "issues": [
          {
            "line": integer,
            "severity": "critical" | "warning" | "suggestion",
            "issue": "short description of the problem",
            "suggestion": "concrete fix"
          }
        ]
      }

      Rules:
      - If the code has no issues, return "issues": [] with a positive summary.
      - Line numbers must refer to the actual line in the code below (first line is line 1).
      - Do not repeat the code back to me.
      - Do not wrap the output in ```json``` fences.

      Code (#{@language}, line numbers added for reference):
      #{numbered_code}

      JSON output:
    PROMPT
  end

  def numbered_code
    @code.lines.each_with_index.map { |line, i| "#{i + 1}: #{line}" }.join
  end

  def parse_response(response)
    Rails.logger.debug("HF Raw Response: #{response.inspect}")

    if response.is_a?(Hash) && response["error"]
      return error_result("API Error: #{response["error"]}", "Check your API key or try again")
    end

    raw_text = extract_generated_text(response)
    extract_structured_result(raw_text)
  end

  def extract_generated_text(response)
    return "" unless response.is_a?(Array)

    response.first&.dig("generated_text").to_s
  end

  def extract_structured_result(raw_text)
    return error_result("Empty AI response", "Try again") if raw_text.blank?

    json_match = raw_text.match(/\{.*\}/m)
    return unparseable_result(raw_text) unless json_match

    parsed = JSON.parse(json_match[0])
    return unparseable_result(raw_text) unless parsed.is_a?(Hash)

    Result.new(
      issues: Array(parsed["issues"]),
      summary: parsed["summary"].presence || "Review completed."
    )
  rescue JSON::ParserError => e
    Rails.logger.error("HF AI JSON Parse Error: #{e.message}")
    unparseable_result(raw_text)
  end

  def unparseable_result(raw_text)
    error_result("AI response not structured", raw_text.truncate(200))
  end

  def empty_result
    Result.new(issues: [], summary: "No code to review.")
  end

  def missing_key_result
    Rails.logger.error("HF AI Error: missing huggingface_api_key credential")
    error_result("AI service not configured", "Set huggingface_api_key in Rails credentials")
  end

  def error_result(issue, suggestion)
    Result.new(
      issues: [{ "line" => 1, "severity" => "critical", "issue" => issue, "suggestion" => suggestion }],
      summary: "Review could not be completed."
    )
  end
end