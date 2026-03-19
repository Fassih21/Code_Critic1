class ReviewsController < ApplicationController
  before_action :set_project
  before_action :set_code_file
  before_action :set_review, only: [:show, :destroy]

  # GET /projects/:project_id/code_files/:code_file_id/reviews
  def index
    @reviews = @code_file.review.present? ? [@code_file.review] : []
  end

  # GET /projects/:project_id/code_files/:code_file_id/reviews/:id
  def show
  end

   def create
    code = @code_file.source_code

    result = AiReviewService.new(code).analyze

    @review = @code_file.create_review(
      result: result.to_json,
      status: "completed"
    )

    redirect_to [@code_file.project, @code_file], notice: "AI review generated"
  end

  private

  def set_code_file
    @code_file = CodeFile.find(params[:code_file_id])
  end
end