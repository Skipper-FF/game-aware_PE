# require 'net/https'
# http = Net::HTTP.new('api.igdb.com/v4',443)
# http.use_ssl = true
# request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'), {'Client-ID' => 'Client ID', 'Authorization' => 'Bearer access_token'})
# request.body = 'fields age_ratings,aggregated_rating,aggregated_rating_count,alternative_names,artworks,bundles,category,checksum,collection,cover,created_at,dlcs,expansions,external_games,first_release_date,follows,franchise,franchises,game_engines,game_modes,genres,hypes,involved_companies,keywords,multiplayer_modes,name,parent_game,platforms,player_perspectives,rating,rating_count,release_dates,screenshots,similar_games,slug,standalone_expansions,status,storyline,summary,tags,themes,total_rating,total_rating_count,updated_at,url,version_parent,version_title,videos,websites;'
# puts http.request(request).body

require 'httparty'

def search_igdb_games(query)
    api_path = '/games'
    @igdb_api_endpoint = 'https://api.igdb.com/v4'
    api_url = @igdb_api_endpoint + api_path
    body_request = "fields similar_games.name where age_ratings.rating < 3, similar_games.age_ratings.rating; search *\"#{query}\"*; limit 1;"
    options = {
      headers: {
        "Authorization": "Bearer 7wk2o0fgv2reiecf6gh3q9weuvn0tm",
        "Client-ID": "7gxcwa6ccp0u9cnegrpzwxbnczg9lr"
      },
      body: body_request
    }
    return_body = HTTParty.post(api_url, options)
    puts JSON.parse(return_body.body)
  end

search_igdb_games('call of duty')
