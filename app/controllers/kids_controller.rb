class KidsController < ApplicationController
  def index
    @kid = policy_scope(Kid)
  end

  def new
    @kid = Kid.new
    authorize @kid
    # @user = current_user
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
  end

  def update
    @kid = Kid.find(params[:id])
    authorize @kid
    @kid.update(kid_params)
  end

  def destroy
    @kid = kid.find(params[:id])
    authorize @kid
    @kid.destroy
    redirect_to dashboard_path
  end

  private

  def kid_params
    params.require(:kid).permit(:user_id, :name, :birthday)
  end
end
