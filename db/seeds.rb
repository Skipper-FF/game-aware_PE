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

puts 'Adding users...'

username = "Toto"
email = "toto@toto.com"
user = User.new(
  username: username,
  email: email,
  password: email
  )
user.save!
puts "#{username} subscribed to Game-Aware"


puts 'Seeding successful'
















