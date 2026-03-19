class CodeFilesController < ApplicationController

  before_action :set_project
  before_action :set_code_file, only: [:show, :destroy]

  def index
    @code_files = @project.code_files
  end

  def show
  end

  def new
    @code_file = @project.code_files.build
  end

  def create
    @code_file = @project.code_files.build(code_file_params)

    if @code_file.save
      redirect_to [@project, @code_file], notice: "Code file created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @code_file.destroy
    redirect_to project_code_files_path(@project), notice: "Code file deleted"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_code_file
    @code_file = @project.code_files.find(params[:id])
  end

  def code_file_params
    params.require(:code_file).permit(:title, :source_code)
  end

end