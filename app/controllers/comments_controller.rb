class CommentsController < ApplicationController
  before_action :set_project
  before_action :set_code_file
  before_action :set_review
  before_action :set_comment, only: [:show, :destroy]

  # GET /projects/:project_id/code_files/:code_file_id/reviews/:review_id/comments
  def index
    @comments = @review.comments.order(created_at: :asc)
  end

  # GET /projects/:project_id/code_files/:code_file_id/reviews/:review_id/comments/:id
  def show
  end

  # POST /projects/:project_id/code_files/:code_file_id/reviews/:review_id/comments
  def create
    @comment = @review.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to project_code_file_review_path(@project, @code_file, @review), notice: "Comment added successfully"
    else
      redirect_to project_code_file_review_path(@project, @code_file, @review), alert: "Failed to add comment"
    end
  end

  # DELETE /projects/:project_id/code_files/:code_file_id/reviews/:review_id/comments/:id
  def destroy
    @comment.destroy
    redirect_to project_code_file_review_path(@project, @code_file, @review), notice: "Comment deleted"
  end

  private

  # Scopes for authorization & nesting
  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_code_file
    @code_file = @project.code_files.find(params[:code_file_id])
  end

  def set_review
    @review = @code_file.review
    redirect_to project_code_file_path(@project, @code_file), alert: "Review not found" unless @review
  end

  def set_comment
    @comment = @review.comments.find(params[:id])
  end

  # Strong params
  def comment_params
    params.require(:comment).permit(:content, :line_number)
  end
end