class UsersController < ApplicationController

  def index
    @users = Rails.cache.fetch("users", expires_in: 12.hours) do
      User.where(active: true).to_a
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "User was successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update 
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user, notice: "User info updated"
    else 
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_path, notice: "User deleted"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end