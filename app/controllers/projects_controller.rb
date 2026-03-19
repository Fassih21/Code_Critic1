class ProjectsController < ApplicationController

  before_action :set_project, only: [:show, :update, :destroy]

  def index
    @projects = Rails.cache.fetch("projects_user_#{current_user.id}", expires_in: 12.hours) do
      current_user.projects.to_a
    end
  end

  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.build(project_params)

    if @project.save
      redirect_to @project, notice: "Project was successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update 
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated"
    else 
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted"
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end