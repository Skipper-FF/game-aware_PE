# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# EsrbContentDescriptor      and     GameContentDescriptor
# EsrbInteractiveElement     and     GameInteractiveElement
# EsrbRatingCategory


require 'json'

puts 'Cleaning database...'
EsrbRatingCategory.destroy_all
EsrbContentDescriptor.destroy_all
EsrbInteractiveElement.destroy_all
puts 'Database cleaned !'

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

puts 'Adding games...'
games['games'].each do | game |
  rating_category = EsrbRatingCategory.find_by(rating: game['rating_category'])
  new_game = Game.new(
    name: game['name'],
    description: game['description'],
    rating_summary: game['rating_summary'],
    esrb_rating_category_id: rating_category.id
    )
  new_game.save!
  game['content_descriptors'].each do | content_descriptor |
    esrb_content_descriptor = EsrbContentDescriptor.find_by(name: content_descriptor)
    unless esrb_content_descriptor.nil?
      new_game_content_descriptor = GameContentDescriptor.new(
      game_id: new_game.id,
      esrb_content_descriptor_id: esrb_content_descriptor.id
      )
      new_game_content_descriptor.save!
    end
  end
  game['interactive_elements'].each do | interactive_element |
    esrb_interactive_element = EsrbInteractiveElement.find_by(name: interactive_element)
    unless esrb_interactive_element.nil?
      new_game_interactive_element = GameInteractiveElement.new(
      game_id: new_game.id,
      esrb_interactive_element_id: esrb_interactive_element.id
      )
      new_game_interactive_element.save!
    end
  end
  puts "#{game['name']} added !"
end
puts 'All games added !'

puts 'Seeding succesful'















