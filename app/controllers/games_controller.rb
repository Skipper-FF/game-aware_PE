require_relative '../services/scraper_service'

class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :search_igdb]

  def index
    if params.dig(:search,:query) && params[:search][:query] != ""
      ScraperService.new(params[:search][:query]).call
      @games = policy_scope(Game).search_by_name(params[:search][:query])
    else
      @games = policy_scope(Game)
    end
  end

  def show
    @game = Game.find(params[:id])
    @user = current_user
    @user_review = UserReview.new
    @rating_category = EsrbRatingCategory.find(@game.esrb_rating_category_id)
    authorize @game
  end
end
