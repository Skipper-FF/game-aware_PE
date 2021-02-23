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
puts 'Opening JSON file...'
esrb_file  = File.read(File.join(Rails.root,esrb_filepath))
esrb = JSON.parse(esrb_file)
puts 'JSON file loaded !'

puts 'Adding rating categories...'
esrb['rating_categories'].each do | rating_category |
  category = EsrbRatingCategory.new(
    name: rating_category['name'],
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

