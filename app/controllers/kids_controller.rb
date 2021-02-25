class KidsController < ApplicationController
  def index
    @kid = policy_scope(Kid)
  end

  def new
    @kid = Kid.new
    authorize @kid
    @user = current_user
  end

  def create
    @kid = Kid.new(kid_params)
    authorize @kid
    @kid.user = current_user
    if @kid.save
      flash[:notice] = 'The kid profile has been added'
      redirect_to dashboard_path
    else
      flash[:notice] = 'An error has occured, please try again.'
      render :new
    end
  end

  def edit
    @kid = Kid.find(params[:id])
    authorize @kid
    @user = current_user
  end

  def update
    @kid = Kid.find(params[:id])
    authorize @kid
    if @kid.update(kid_params)
      flash[:notice] = 'The kid profile has been edited'
      redirect_to dashboard_path
    else
      flash[:notice] = 'An error has occured, please try again.'
    end
  end

  def destroy
    @kid = Kid.find(params[:id])
    authorize @kid
    if @kid.destroy
      flash[:notice] = 'The kid profile has been edited'
      redirect_to dashboard_path
    else
      flash[:notice] = 'An error has occured, please try again.'
    end
  end

  private

  def kid_params
    params.require(:kid).permit(:user_id, :name, :birthdate)
  end
end
