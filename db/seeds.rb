require 'faker'
require 'json'
require "open-uri"

# sets Faker with French values
Faker::Config.locale = 'fr'

puts 'Cleaning database...'
UserReview.destroy_all
Kid.destroy_all
User.destroy_all
GameInteractiveElement.destroy_all
GameContentDescriptor.destroy_all
Game.destroy_all
EsrbRatingCategory.destroy_all
EsrbContentDescriptor.destroy_all
EsrbInteractiveElement.destroy_all
puts 'Database cleaned !'
puts''

esrb_filepath = 'db/seeds/esrb.json'
esrb_file  = File.read(File.join(Rails.root,esrb_filepath))
esrb = JSON.parse(esrb_file)

puts 'Adding rating categories...'
esrb['rating_categories'].each do | rating_category |
  category = EsrbRatingCategory.new(
    name: rating_category['name'],
    rating: rating_category['rating'],
    description: rating_category['description']
    )
  category.save!
end
puts 'Rating categories added !'

puts 'Adding content descriptors...'
esrb['content_descriptors'].each do | content_descriptor |
  descriptor = EsrbContentDescriptor.new(
    name: content_descriptor['name'],
    description: content_descriptor['description']
    )
  descriptor.save!
end
puts 'Content descriptors added !'

puts 'Adding interactive elements...'
esrb['interactive_elements'].each do | interactive_element |
  element = EsrbInteractiveElement.new(
    name: interactive_element['name'],
    description: interactive_element['description']
    )
  element.save!
end
puts 'Interactive elements added !'

games_filepath = 'db/seeds/games.json'
games_file = File.read(File.join(Rails.root,games_filepath))
games = JSON.parse(games_file)

# puts 'Adding games...'
# games['games'].each do | game |
#   rating_category = EsrbRatingCategory.find_by(rating: game['rating_category'])
#   new_game = Game.new(
#     name: game['name'],
#     description: game['description'],
#     rating_summary: game['rating_summary'],
#     esrb_rating_category_id: rating_category.id
#     )
#   new_game.save!
#   cover_file = URI.open(game['cover'])
#   cover_filename = cover_file.base_uri.to_s.split('/')[-1]
#   new_game.photo.attach(io: cover_file, filename: cover_filename, content_type: cover_file.content_type)
#   game['content_descriptors'].each do | content_descriptor |
#     esrb_content_descriptor = EsrbContentDescriptor.find_by(name: content_descriptor)
#     unless esrb_content_descriptor.nil?
#       new_game_content_descriptor = GameContentDescriptor.new(
#       game_id: new_game.id,
#       esrb_content_descriptor_id: esrb_content_descriptor.id
#       )
#       new_game_content_descriptor.save!
#     end
#   end
#   game['interactive_elements'].each do | interactive_element |
#     esrb_interactive_element = EsrbInteractiveElement.find_by(name: interactive_element)
#     unless esrb_interactive_element.nil?
#       new_game_interactive_element = GameInteractiveElement.new(
#       game_id: new_game.id,
#       esrb_interactive_element_id: esrb_interactive_element.id
#       )
#       new_game_interactive_element.save!
#     end
#   end
#   puts "#{game['name']} added !"
# end
# puts 'All games added !'

# puts 'Adding users...'
# 5.times do
#   firstname = Faker::Name.first_name
#   username = firstname.parameterize + Faker::Number.decimal_part(digits: 3)
#   email = Faker::Internet.free_email(name: username.downcase)
#   user = User.new(
#     username: username,
#     email: email,
#     password: email
#     )
#   user.save!
#   puts "#{username} subscribed to Game-Aware"
#   [1, 2].sample.times do
#     name = Faker::Name.first_name
#     birthdate = Faker::Date.birthday(min_age: 3, max_age: 17)
#     kid = Kid.new(
#       name: name,
#       birthdate: birthdate,
#       user_id: user.id
#       )
#     kid.save!
#     puts "and wants the best games for #{name} !"
#   end
# end

# puts 'Adding reviews'
# 20.times do
#   user_id = User.find(User.pluck(:id).sample).id
#   game_id = Game.find(Game.pluck(:id).sample).id
#   age = rand(3..17)
#   title = Faker::Lorem.sentence(word_count: 2)
#   description = Faker::Lorem.paragraph(sentence_count: 3)
#   rating = rand(1..5)
#   review = UserReview.new(
#     user_id: user_id,
#     game_id: game_id,
#     age: age,
#     title: title,
#     description: description,
#     rating: rating
#     )
#   review.save!
#   puts "#{user_id} left a review for game #{game_id}"
# end

puts 'Seeding successful'

require 'httparty'
require 'open-uri'


# variables for ESRB
@esrb_url = 'https://www.esrb.org/wp-admin/admin-ajax.php'

# variables for IGDB
@client_id = '7gxcwa6ccp0u9cnegrpzwxbnczg9lr'
# @client_secret = 'j25t3ot9n7w893ozoxkyu943e7k61t'
# @twitch_url = 'https://id.twitch.tv/oauth2/token'
@igdb_api_endpoint = 'https://api.igdb.com/v4'

# temp access_token
@access_token = 'r3lxrkp7t1ok3c8n3uyev8yxayr8a6'

def search_game
  puts 'What game are you looking for ?'
  print '> '
  "gta"
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
  return_body = HTTParty.post(api_url, options)
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

def set_description(description)
  if description.nil?
    return ""
  else
    return description
  end
end

def store_to_db(igdb_game, esrb_info, game_cover)
  description = set_description(igdb_game['summary'])
  if esrb_info.nil?
    rating_category = EsrbRatingCategory.find_by(rating: "RP")
    new_game = Game.new(
      name: igdb_game['name'],
      igdb_id: igdb_game['id'],
      description: description,
      rating_summary: "No ESRB rating for this game",
      esrb_rating_category_id: rating_category.id
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
      esrb_rating_category_id: rating_category.id
      )
    new_game.save!
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
  # add cover
  if game_cover[0]['url'].nil?
    nocover_file  = File.open(File.join(Rails.root,'app/assets/images/nocover.jpg'))
    new_game.photo.attach(io: nocover_file, filename: 'nocover.jpg', content_type: 'image/png')
  else
    cover_file = URI.open("https:#{game_cover[0]['url']}")
    cover_filename = cover_file.base_uri.to_s.split('/')[-1]
    new_game.photo.attach(io: cover_file, filename: cover_filename, content_type: cover_file.content_type)
  end
end

query = search_game
igdb_games = search_igdb_games(query)
igdb_games.each do |igdb_game|
  puts "==============================="
  puts "Processing #{igdb_game['name']}"
  if Game.find_by(igdb_id: igdb_game['id']).nil?
    esrb_info = search_esrb(igdb_game['name'])
    game_cover = search_igdb_cover(igdb_game['cover'])
    store_to_db(igdb_game, esrb_info, game_cover)
    puts "#{igdb_game['name']} is saved"
  else
    puts "#{igdb_game['name']} is already in DB"
  end
  puts "#{igdb_game['name']} processed !"
  # find out how to add photos if empty => puts game['cover'].class
end
















