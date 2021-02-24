class UserReviewsController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @user_review = UserReview.new
    authorize @user_review
  end

  def create
    @user = User.find(params[:user_id])
    @user_review = UserReview.new(user_reviews_params)
    authorize @user_review
    @user_review.user = @user
    @user_review.user = current_user
    if @user_review.save
      # flash[:notice] = 'Votre commentaire a bien été ajouté!'
      redirect_to game_path
    else
      # flash[:notice] = 'Il y a une erreur, veuillez réessayer'
      render :new
    end
  end

  def edit
    set_user_review
    authorize @user_review
  end

  def update
    set_user_review
    authorize @user_review
    @user_review.update(user_reviews_params)
    redirect_to game_path(@user_review)
  end

  def destroy
    set_user_review
    authorize @user_review
    @user_review.destroy
    # flash[:notice] = 'Votre commentaire a bien été supprimé!'
    redirect_to game_path
  end

  private

  def set_user_review
    @user_review = UserReview.find(params[:id])
  end

  def user_reviews_params
    params.require(:user_reviews).permit(:age, :title, :description, :rating, :user_id, :game_id)
  end
end
