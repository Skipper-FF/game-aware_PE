require 'httparty'

# variables for ESRB
@esrb_url = 'https://www.esrb.org/wp-admin/admin-ajax.php'
@search_keyword = nil
@pg = 1
@games_found = 0
@total_games = 1

# variables for IGDB
@client_id = '7gxcwa6ccp0u9cnegrpzwxbnczg9lr'
@client_secret = 'j25t3ot9n7w893ozoxkyu943e7k61t'
@twitch_url = 'https://id.twitch.tv/oauth2/token'
@api_endpoint = 'https://api.igdb.com/v4'

# temp access_token
@access_token = 'r3lxrkp7t1ok3c8n3uyev8yxayr8a6'
# def new_access_token
#   file = File.read('./access_token.json')
#   data_hash = JSON.parse(file)
#   uri = URI(@twitch_url)
#   res = Net::HTTP.post_form(uri, 'client_id' => @client_id, 'client_secret' => @client_secret, 'grant_type' => 'client_credentials')
#   my_hash = JSON.parse(res.body) # returns 'access_token'  'expires_in' 'token_type'
#   data_hash["access_token"] = my_hash['access_token']
#   data_hash["expires_in"] = my_hash['expires_in']
#   File.write('./access_token.json', JSON.dump(data_hash))
# end

def search_keyword
  puts 'What game are you looking for ?'
  print '> '
  @search_keyword = gets.chomp
end

def store_games(game)
  rating_category = EsrbRatingCategory.find_by(rating: game['rating'])
  igdb_values = search_igdb(game['title'])
  new_game = Game.new(
    name: game['title'],
    description: "",
    rating_summary: game['synopsis'],
    esrb_rating_category_id: rating_category.id,
    esrb_id: game['certificate']
    )
  new_game.save!
  descriptors = game['descriptors'].split(",").map(&:strip)
  descriptors.each do | content_descriptor |
    esrb_content_descriptor = EsrbContentDescriptor.find_by(name: content_descriptor)
    unless esrb_content_descriptor.nil?
      new_game_content_descriptor = GameContentDescriptor.new(
      game_id: new_game.id,
      esrb_content_descriptor_id: esrb_content_descriptor.id
      )
      new_game_content_descriptor.save!
    end
  end
  interactive_elements = game['Online_Notice'].split("&lt;br /&gt;").map(&:strip)
  interactive_elements.each do | interactive_element |
    esrb_interactive_element = EsrbInteractiveElement.find_by(name: interactive_element)
    unless esrb_interactive_element.nil?
      new_game_interactive_element = GameInteractiveElement.new(
      game_id: new_game.id,
      esrb_interactive_element_id: esrb_interactive_element.id
      )
      new_game_interactive_element.save!
    end
  end
  puts "#{game['title']} added to DB"
end

def search_esrb
  options = {
    body: {
      "action": 'search_rating',
      "args[searchKeyword]": @search_keyword,
      "args[pg]": @pg
    }
  }
  return_body = HTTParty.post(@esrb_url, options)
  results = JSON.parse(return_body.body)
  results['games'].each do |game|
    if Game.find_by(esrb_id: game['certificate']).nil?
      store_games(game)
    else
      puts "#{game['title']} is already in DB"
    end
  end
  @total_games = results['total'].to_i
  @games_found += results['found'].to_i
  @pg += 1
end

def search_igdb(query)
  api_path = '/games'
  api_url = @api_endpoint + api_path
  body_request = "where name ~ \"#{query}\";"
  options = {
    headers: {
      "Authorization": "Bearer #{@access_token}",
      "Client-ID": @client_id
    },
    body: body_request
  }
  return_body = HTTParty.post(api_url, options)
  results = JSON.parse(return_body.body)
  results
end

search_keyword
while @games_found < @total_games
    search_esrb
end
