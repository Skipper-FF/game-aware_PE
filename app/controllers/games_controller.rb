class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @game = policy_scope(Game)
  end

  def show
    @game = Game.find(params[:id])
    @user = current_user
    @user_review = UserReview.new
    @rating_category = EsrbRatingCategory.find(@game.esrb_rating_category_id)
    authorize @game

  end

end
