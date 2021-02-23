class UserReviewsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])

  end

  def new
    @user_review = UserReviews.new
    authorize @user_review
    @game = Game.find(params[:game_id])
    raise
  end

  def create
    @user_review = UserReviews.new(user_reviews_params)
    authorize @user_review
    @game = Game.find(params[:game_id])
    @user_review.game = @game
    @user_review.user = current_user
    if @user_reviews.save
      flash[:notice] = 'Votre commentaire a bien été ajouté'
      redirect_to game_path
    else
      flash[:notice] = 'Il y a une erreur, veuillez réessayer'
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def user_reviews_params
    params.require(:user_reviews).permit(:age, :title, :description, :rating, :user_id, :game_id)
  end
end
