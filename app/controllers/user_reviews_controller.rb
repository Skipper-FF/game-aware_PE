class UserReviewsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @user_reviews = UserReview.all
  end
  def new
    @game = Game.find(params[:game_id])
    @user_review = UserReview.new
    authorize @user_review
  end

  def create
    @game = Game.find(params[:game_id])
    @user_review = UserReview.new(user_reviews_params)
    authorize @user_review
    @user_review.user = current_user
    @user_review.game = @game
    if @user_review.save
      flash[:notice] = 'Your review has been added'
      redirect_to game_path(@game)
    else
      flash[:notice] = 'An error has occured, please try again.'
      # render :partial => "user_reviews/new", :object => @user_review
      @user = current_user
      @rating_category = EsrbRatingCategory.find(@game.esrb_rating_category_id)
      render "games/show"
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
    flash[:notice] = 'Your review has been edited'
    redirect_to game_path(@user_review.game)
  end

  def destroy
    set_user_review
    authorize @user_review
    @user_review.destroy
    flash[:notice] = 'Your review has been removed!'
    redirect_to game_path(@user_review.game)
  end

  private

  def set_user_review
    @user_review = UserReview.find(params[:id])
  end

  def user_reviews_params
    params.require(:user_review).permit(:age, :title, :description, :rating, :user_id, :game_id)
  end
end
