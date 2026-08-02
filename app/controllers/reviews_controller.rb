class ReviewsController < ApplicationController
  before_action :set_code_file, only: [:show, :destroy]
  before_action :set_review, only: [:show, :destroy]

  before_action :authenticate_user!

  def create
    code_file = CodeFile.find(params[:code_file_id])
    review = code_file.build_review
    authorize review

    Review.where(code_file_id: code_file.id).destroy_all

    result = AiReviewService.new(code_file).analyze

    review = Review.new(
      code_file_id: code_file.id,
      result: result.issues.to_json,
      summary: result.summary,
      status: "completed"
    )
    review.save!

    redirect_to code_file_path(code_file), notice: "AI review generated"
  end

  def show
    authorize @review
  end

  def destroy
    authorize @review
    @review.destroy
    redirect_to code_file_path(@code_file), notice: "Review deleted"
  end

  private

  def set_code_file
    @code_file = CodeFile.find(params[:code_file_id])
  end

  def set_review
    @review = @code_file.review
  end
end