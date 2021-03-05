require 'json'

require_relative '../app/services/igdb_scraper_service'

esrb_filepath = 'db/seeds/esrb.json'
genres_filepath = 'db/seeds/genres.json'
games_filepath = 'db/seeds/games.json'

puts 'Cleaning database...'
UserReview.destroy_all
Kid.destroy_all
User.destroy_all
GameInteractiveElement.destroy_all
GameContentDescriptor.destroy_all
EsrbContentDescriptor.destroy_all
EsrbInteractiveElement.destroy_all
GameGenre.destroy_all
Genre.destroy_all
EsrbRatingCategory.destroy_all

puts 'Database cleaned !'
puts''

esrb_file  = File.read(File.join(Rails.root,esrb_filepath))
esrb = JSON.parse(esrb_file)

puts 'Adding rating categories...'
esrb['rating_categories'].each do | rating_category |
  category = EsrbRatingCategory.new(
    name: rating_category['name'],
    rating: rating_category['rating'],
    age: rating_category['age'],
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

genres_file  = File.read(File.join(Rails.root,genres_filepath))
genres = JSON.parse(genres_file)

puts 'Adding Genres...'
genres['genres'].each do | genre |
  element = Genre.new(
    name: genre['name'],
    igdb_id: genre['id']
    )
  element.save!
end
puts 'Genre added !'

games_file = File.read(File.join(Rails.root,games_filepath))
games = JSON.parse(games_file)

games['games'].each { |game| IgdbScraperService.new(game).call }

puts 'Seeding successful'
