require 'httparty'
require 'open-uri'
require 'json'

class IgdbScraperService
  def initialize(query)
    @query = query
    @client_id = '7gxcwa6ccp0u9cnegrpzwxbnczg9lr'
    @client_secret = ENV["TWITCH_CLIENT_SECRET"]
    @twitch_url = 'https://id.twitch.tv/oauth2/token'
    @igdb_api_endpoint = 'https://api.igdb.com/v4'
  end

  def call
    @access_token = new_igdb_token['access_token']
    igdb_games = search_igdb_games
    return if igdb_games == ""

    # igdb_games.reject! { |game| game.key?('parent_game') }
    igdb_games.each do |igdb_game|
      if Game.find_by(igdb_id: igdb_game['id']).nil?
        game_cover = [{}]
        unless igdb_game['cover'].nil?
          game_cover = search_igdb_cover(igdb_game['cover'])
        end
        alt_names = nil
        unless igdb_game['alternative_names'].nil?
          alt_names = ""
          igdb_game['alternative_names'].each do |alt_id|
            alt_names << "#{search_igdb_alternative_names(alt_id)[0]['name']}, "
          end
        end
        store_to_db(igdb_game, game_cover, alt_names)
      end
    end
    revoke_token
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

  def revoke_token
    options = {
      query: {
        "client_id": @client_id,
        "token": @access_token
      }
    }
    HTTParty.post('https://id.twitch.tv/oauth2/revoke', options)
  end

  def httparty_options(body)
    {
      headers: {
        "Authorization": "Bearer #{@access_token}",
        "Client-ID": @client_id
      },
      body: body
    }
  end

  def search_igdb_games
    api_path = '/games'
    api_url = @igdb_api_endpoint + api_path
    body = "fields name,
            id, summary, cover, alternative_names;
            search *\"#{@query}\"*;
            where version_parent = null & parent_game = null;
            limit 50;"
    options = httparty_options(body)
    response = HTTParty.post(api_url, options)
    return "" if response.code != 200

    JSON.parse(response.body)
  end

  def search_igdb_cover(id)
    api_path = '/covers'
    api_url = @igdb_api_endpoint + api_path
    body = "fields url; where id = #{id};"
    options = httparty_options(body)
    response = HTTParty.post(api_url, options)
    return "" if response.code != 200

    JSON.parse(response.body)
  end

  def search_igdb_alternative_names(id)
    api_path = "/alternative_names"
    api_url = @igdb_api_endpoint + api_path
    body = "fields name; where id = #{id};"
    options = httparty_options(body)
    response = HTTParty.post(api_url, options)
    return "" if response.code != 200

    JSON.parse(response.body)
  end

  def fill_description(description)
    return "" if description.nil?

    description
  end

  def store_to_db(igdb_game, game_cover, alt_names)
    description = fill_description(igdb_game['summary'])
    new_game = Game.new(
      name: igdb_game['name'],
      igdb_id: igdb_game['id'],
      description: description,
      alternative_names: alt_names
    )
    new_game.save!
    # add cover
    if game_cover[0]['url'].nil? || game_cover[0].empty?
      new_game.cover_url = "https://images.igdb.com/igdb/image/upload/t_cover_big/nocover_qhhlj6.jpg"
    else
      new_game.cover_url = "https:#{game_cover[0]['url']}".sub('thumb', '720p')
    end
    new_game.save!
  end
end
