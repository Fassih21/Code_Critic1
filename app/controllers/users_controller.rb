class UsersController < ApplicationController
  before_action :authenticate_user!
  def show
    @user = current_user
  end

  def update 
    @user = current_user

    if @user.update(user_params)
      redirect_to user_path, notice: "User info updated"
    else 
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end