require 'httparty'
require 'json'

class EsrbScraperService
  def initialize(id, name)
    @id = id
    @name = name
    @esrb_url = 'https://www.esrb.org/wp-admin/admin-ajax.php'
  end

  def call
    esrb_info = search_esrb
    store_to_db(@id, esrb_info)
  end

  private

  def search_esrb
    options = {
      body: {
        "action": 'search_rating',
        "args[searchKeyword]": @name
      }
    }
    response = HTTParty.post(@esrb_url, options)
    results = JSON.parse(response.body)
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

  def store_to_db(id, esrb_info)
    game_to_update = Game.find(id)
    if esrb_info.nil?
      rating_category = EsrbRatingCategory.find_by(rating: "RP")
      game_to_update.rating_summary = "No ESRB rating for this game"
      game_to_update.esrb_rating_category_id = rating_category.id
      game_to_update.save!
    else
      rating_category = EsrbRatingCategory.find_by(rating: esrb_info[:esrb_rating_category_id])
      game_to_update.rating_summary = esrb_info[:rating_summary]
      game_to_update.esrb_id = esrb_info[:esrb_id]
      game_to_update.esrb_rating_category_id = rating_category.id
      game_to_update.save!
      esrb_info[:esrb_content_descriptors].each do |content_descriptor|
        esrb_content_descriptor = EsrbContentDescriptor.find_by(name: content_descriptor)
        unless esrb_content_descriptor.nil?
          game_to_update_content_descriptor = GameContentDescriptor.new(
            game_id: game_to_update.id,
            esrb_content_descriptor_id: esrb_content_descriptor.id
          )
          game_to_update_content_descriptor.save!
        end
      end
      esrb_info[:esrb_interactive_elements].each do |interactive_element|
        esrb_interactive_element = EsrbInteractiveElement.find_by(name: interactive_element)
        unless esrb_interactive_element.nil?
          game_to_update_interactive_element = GameInteractiveElement.new(
            game_id: game_to_update.id,
            esrb_interactive_element_id: esrb_interactive_element.id
          )
          game_to_update_interactive_element.save!
        end
      end
    end
  end
end
