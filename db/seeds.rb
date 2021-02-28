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















