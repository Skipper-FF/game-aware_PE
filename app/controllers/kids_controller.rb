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
      flash[:notice] = 'Votre enfant a bien été ajouté'
      redirect_to dashboard_path
    else
      flash[:notice] = 'Il y a eu une erreur, veuillez réessayer'
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
      flash[:notice] = 'Kid updated'
      redirect_to dashboard_path
    else
      flash[:notice] = 'hmmm, an error has occured, please try again'
    end
  end

  def destroy
    @kid = Kid.find(params[:id])
    authorize @kid
    if @kid.destroy
      flash[:notice] = 'Kid deleted'
      redirect_to dashboard_path
    else
      flash[:notice] = 'hmmm, an error has occured, please try again'
    end
  end

  private

  def kid_params
    params.require(:kid).permit(:user_id, :name, :birthdate)
  end
end
