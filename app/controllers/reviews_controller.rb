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

  # POST /projects/:project_id/code_files/:code_file_id/reviews
  def create
    # Call the AI service
    result = AiReviewService.new(@code_file.source_code).analyze

    @review = @code_file.build_review(
      result: result,
      status: "completed"
    )

    if @review.save
      redirect_to [@project, @code_file, @review], notice: "Review completed successfully"
    else
      redirect_to [@project, @code_file], alert: "Failed to create review"
    end
  end

  # DELETE /projects/:project_id/code_files/:code_file_id/reviews/:id
  def destroy
    @review.destroy
    redirect_to project_code_file_reviews_path(@project, @code_file), notice: "Review deleted"
  end

  private

  # Set project based on current_user (authorization)
  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  # Set code file scoped to project
  def set_code_file
    @code_file = @project.code_files.find(params[:code_file_id])
  end

  # Set review scoped to code file
  def set_review
    @review = @code_file.review
    redirect_to project_code_file_path(@project, @code_file), alert: "Review not found" unless @review
  end
end