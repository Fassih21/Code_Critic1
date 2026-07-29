class ReviewsController < ApplicationController
  before_action :set_code_file, only: [:show, :destroy]
  before_action :set_review, only: [:show, :destroy]

  before_action :authenticate_user!
def create
  code_file_id = params[:code_file_id].to_i
  code_file = CodeFile.find(code_file_id)
  @review = Review.new(code_file: code_file)
  authorize @review

  code = code_file.content.to_s.dup
  Review.where(code_file_id: code_file_id).destroy_all

  result = AiReviewServices.new(code).analyze

  review = Review.new
  review.code_file_id = code_file_id
  review.result = result.empty? ? [].to_json : result.to_json
  review.status = "completed"
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