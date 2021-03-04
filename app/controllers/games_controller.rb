require_relative '../services/igdb_scraper_service'
require_relative '../services/esrb_scraper_service'

class GamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :search_igdb]

  def index
    if params.dig(:search,:query) && params[:search][:query] != ""
      IgdbScraperService.new(params[:search][:query]).call
      @games = policy_scope(Game).search_by_name(params[:search][:query]).order(:name).page(params[:page]).per(10)
    else
      @games = policy_scope(Game).order(:name).page(params[:page]).per(10)
    end
  end

  def show
    game = Game.find(params[:id])
    EsrbScraperService.new(game.id, game.name).call if game.esrb_id.nil?
    @game = Game.find(params[:id])
    @user = current_user
    @user_review = UserReview.new
    @rating_category = EsrbRatingCategory.find(@game.esrb_rating_category_id)
    authorize @game
  end
end
