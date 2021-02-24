class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @game = policy_scope(Game)
  end

  def show
    @game = Game.find(params[:id])
    @rating_category = EsrbRatingCategory.find(@game.esrb_rating_category_id)
    authorize @game
  end
end
