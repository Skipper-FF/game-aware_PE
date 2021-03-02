require 'httparty'
require 'open-uri'
require 'json'

class ScraperService
  def initialize(query)
    @query = query
    @client_id = '7gxcwa6ccp0u9cnegrpzwxbnczg9lr'
    @client_secret = ENV["TWITCH_CLIENT_SECRET"]
    @twitch_url = 'https://id.twitch.tv/oauth2/token'
    @igdb_api_endpoint = 'https://api.igdb.com/v4'
    @esrb_url = 'https://www.esrb.org/wp-admin/admin-ajax.php'
  end

  def call
    access_token = new_igdb_token['access_token']
    igdb_games = search_igdb_games(access_token)
    return if igdb_games == ""

    igdb_games.each do |igdb_game|
      if Game.find_by(igdb_id: igdb_game['id']).nil?
        esrb_info = search_esrb(igdb_game['name'])
        game_cover = [{}]
        unless igdb_game['cover'].nil?
          game_cover = search_igdb_cover(igdb_game['cover'], access_token)
        end
        alt_names = nil
        unless igdb_game['alternative_names'].nil?
          alt_names = ""
          igdb_game['alternative_names'].each do |alt_id|
            alt_names << "#{search_igd_alternative_names(alt_id)[0]['name']}, "
          end
        end
        store_to_db(igdb_game, esrb_info, game_cover, alt_names)
      end
    end
  end

  private

  def new_igdb_token
    options = {
      query: {
        "client_id": @client_id,
        "client_secret": @client_secret,
        "grant_type": "client_credentials"
      }
    }
    response = HTTParty.post(@twitch_url, options)
    JSON.parse(response.body)
  end

  def search_igdb_games(access_token)
    api_path = '/games'
    api_url = @igdb_api_endpoint + api_path
    body_request = "fields name, id, summary, cover, alternative_names; search *\"#{@query}\"*; limit 50;"
    options = {
      headers: {
        "Authorization": "Bearer #{access_token}",
        "Client-ID": @client_id
      },
      body: body_request
    }
    response = HTTParty.post(api_url, options)
    return "" if response.code != 200

    JSON.parse(response.body)
  end

  def search_igdb_cover(id, access_token)
    api_path = '/covers'
    api_url = @igdb_api_endpoint + api_path
    body_request = "fields url; where id = #{id};"
    options = {
      headers: {
        "Authorization": "Bearer #{access_token}",
        "Client-ID": @client_id
      },
      body: body_request
    }
    response = HTTParty.post(api_url, options)
    return "" if response.code != 200

    JSON.parse(response.body)
  end

  def search_igd_alternative_names(id, access_token)
    api_path = "/alternative_names"
    api_url = @igdb_api_endpoint + api_path
    body_request = "fields name; where id = #{id};"
    options = {
      headers: {
        "Authorization": "Bearer #{access_token}",
        "Client-ID": @client_id
      },
      body: body_request
    }
    response = HTTParty.post(api_url, options)
    return "" if response.code != 200

    JSON.parse(response.body)
  end

  def search_esrb(game)
    options = {
      body: {
        "action": 'search_rating',
        "args[searchKeyword]": game
      }
    }
    return_body = HTTParty.post(@esrb_url, options)
    results = JSON.parse(return_body.body)
    if results['games'][0].nil?
      esrb_game = nil
    else
      esrb_game = {
        esrb_id: results['games'][0]['certificate'],
        rating_summary: results['games'][0]['synopsis'],
        esrb_rating_category_id: results['games'][0]['rating'],
        esrb_content_descriptors: results['games'][0]['descriptors'].split(",").map(&:strip),
        esrb_interactive_elements: results['games'][0]['Online_Notice'].split("&lt;br /&gt;").map(&:strip)
      }
    end
    esrb_game
  end

  def set_description(description)
    return "" if description.nil?

    description
  end

  def store_to_db(igdb_game, esrb_info, game_cover, alt_names)
    description = set_description(igdb_game['summary'])
    if esrb_info.nil?
      rating_category = EsrbRatingCategory.find_by(rating: "RP")
      new_game = Game.new(
        name: igdb_game['name'],
        igdb_id: igdb_game['id'],
        description: description,
        rating_summary: "No ESRB rating for this game",
        esrb_rating_category_id: rating_category.id,
        alternative_names: alt_names
      )
      new_game.save!
    else
      rating_category = EsrbRatingCategory.find_by(rating: esrb_info[:esrb_rating_category_id])
      new_game = Game.new(
        name: igdb_game['name'],
        igdb_id: igdb_game['id'],
        description: description,
        rating_summary: esrb_info[:rating_summary],
        esrb_id: esrb_info[:esrb_id],
        esrb_rating_category_id: rating_category.id,
        alternative_names: alt_names
      )
      new_game.save!
      esrb_info[:esrb_content_descriptors].each do |content_descriptor|
        esrb_content_descriptor = EsrbContentDescriptor.find_by(name: content_descriptor)
        unless esrb_content_descriptor.nil?
          new_game_content_descriptor = GameContentDescriptor.new(
            game_id: new_game.id,
            esrb_content_descriptor_id: esrb_content_descriptor.id
          )
          new_game_content_descriptor.save!
        end
      end
      esrb_info[:esrb_interactive_elements].each do |interactive_element|
        esrb_interactive_element = EsrbInteractiveElement.find_by(name: interactive_element)
        unless esrb_interactive_element.nil?
          new_game_interactive_element = GameInteractiveElement.new(
            game_id: new_game.id,
            esrb_interactive_element_id: esrb_interactive_element.id
          )
          new_game_interactive_element.save!
        end
      end
    end
    # add cover
    if game_cover[0]['url'].nil? || game_cover[0].empty?
      new_game.cover_url = "https://images.igdb.com/igdb/image/upload/t_cover_big/nocover_qhhlj6.jpg"
    else
      new_game.cover_url = "https:#{game_cover[0]['url']}"
    end
    new_game.save!
  end
end
