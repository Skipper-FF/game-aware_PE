require 'httparty'
require 'open-uri'
require 'pry-byebug'

# @search_game = nil
# variables for ESRB
@esrb_url = 'https://www.esrb.org/wp-admin/admin-ajax.php'
@pg = 1
@games_found = 0
@total_games = 1
@rating_category = EsrbRatingCategory.find_by(rating: "RP")

# variables for IGDB
@client_id = '7gxcwa6ccp0u9cnegrpzwxbnczg9lr'
@client_secret = 'j25t3ot9n7w893ozoxkyu943e7k61t'
@twitch_url = 'https://id.twitch.tv/oauth2/token'
@igdb_api_endpoint = 'https://api.igdb.com/v4'

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

def search_game
  puts 'What game are you looking for ?'
  print '> '
  gets.chomp
end

def search_esrb(game)
  options = {
    body: {
      "action": 'search_rating',
      "args[searchKeyword]": game,
      "args[pg]": @pg
    }
  }
  puts "Querying ESRB for #{game}"
  return_body = HTTParty.post(@esrb_url, options)
  puts "ESRB query ok"
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
  # results['games'].each do |game|
  #   if Game.find_by(esrb_id: game['certificate']).nil?
  #     store_games(game)
  #   else
  #     puts "#{game['title']} is already in DB"
  #   end
  # end
  # @total_games = results['total'].to_i
  # @games_found += results['found'].to_i
  # @pg += 1
end

def search_igdb_cover(id)
  api_path = '/covers'
  api_url = @igdb_api_endpoint + api_path
  body_request = "fields url; where id = #{id};"
  options = {
    headers: {
      "Authorization": "Bearer #{@access_token}",
      "Client-ID": @client_id
    },
    body: body_request
  }
  puts "Querying IGDB cover"
  return_body = HTTParty.post(api_url, options)
  puts "IGDB cover query ok"
  JSON.parse(return_body.body)
end

def search_igdb_games(query)
  api_path = '/games'
  api_url = @igdb_api_endpoint + api_path
  body_request = "fields name, id, summary, cover; search *\"#{query}\"*; limit 50;"
  options = {
    headers: {
      "Authorization": "Bearer #{@access_token}",
      "Client-ID": @client_id
    },
    body: body_request
  }
  puts "Querying IGDB games"
  return_body = HTTParty.post(api_url, options)
  puts "IGDB games query ok"
  JSON.parse(return_body.body)
end

def store_to_db(igdb_game, esrb_info, game_cover)
  puts @rating_category
  if esrb_info.nil?
    puts "Entering save with no ESRB info"
    puts @rating_category
    puts "ok"
    # rating_category = EsrbRatingCategory.find_by(rating: "RP")
    p igdb_game
    p esrb_info
    new_game = Game.new(
      name: igdb_game['name'],
      igdb_id: igdb_game['id'],
      description: igdb_game['summary'],
      rating_summary: "No ESRB rating for this game",
      esrb_rating_category_id: 1
      )
    new_game.save!
    puts "#{igdb_game['name']} is saved"
  else
    puts "Entering save with ESRB info"
    p esrb_info[:esrb_rating_category_id]
    rating_category = EsrbRatingCategory.find_by(rating: esrb_info[:esrb_rating_category_id])
    p igdb_game
    p esrb_info
    new_game = Game.new(
      name: igdb_game['name'],
      igdb_id: igdb_game['id'],
      description: igdb_game['summary'],
      rating_summary: esrb_info[:rating_summary],
      esrb_id: esrb_info[:esrb_id],
      esrb_rating_category_id: rating_category.id
      )
    new_game.save!
    puts "#{igdb_game['name']} is saved"
    esrb_info[:esrb_content_descriptors].each do | content_descriptor |
      esrb_content_descriptor = EsrbContentDescriptor.find_by(name: content_descriptor)
      unless esrb_content_descriptor.nil?
        new_game_content_descriptor = GameContentDescriptor.new(
          game_id: new_game.id,
          esrb_content_descriptor_id: esrb_content_descriptor.id
          )
        new_game_content_descriptor.save!
      end
    end
    puts "#{igdb_game['name']} content descriptor are saved"
    esrb_info[:esrb_interactive_elements].each do | interactive_element |
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
  "#{igdb_game['name']} interactive elements are saved"
  # add cover
  cover_file = URI.open("https:#{game_cover[0]['url']}")
  cover_filename = cover_file.base_uri.to_s.split('/')[-1]
  new_game.photo.attach(io: cover_file, filename: cover_filename, content_type: cover_file.content_type)
  puts "#{igdb_game['name']} cover is saved"
end

query = search_game
puts "Entering IGDB"
igdb_games = search_igdb_games(query)
# if games.any?
#   puts "on continue!"
# else
#   puts "Pas de jeu"
# end
igdb_games.each do |igdb_game|
  puts "==============================="
  puts "Processing #{igdb_game['name']}"
  if Game.find_by(igdb_id: igdb_game['id']).nil?
    puts "Entering ESRB"
    puts igdb_game['name']
    esrb_info = search_esrb(igdb_game['name'])
    puts "Entering IGDB cover"
    game_cover = search_igdb_cover(igdb_game['cover'])
    store_to_db(igdb_game, esrb_info, game_cover)
  else
    puts "#{igdb_game['name']} is already in DB"
  end
  puts "#{igdb_game['name']} processed !"
  # find out how to add photos if empty => puts game['cover'].class
end


#champ de la recherche => search_game
#recherche sur igdb => search_igdb_games
## récuper name, id, summary, cover
## si résultat, stocker dans variable
# recherche cover sur igdb => search_igdb_cover
## stocker url dans variable
# recherche sur esrb => search_esrb
## stocker info dans variable
# envoyer variable pour sauvegarde db => store_to_db(games)
