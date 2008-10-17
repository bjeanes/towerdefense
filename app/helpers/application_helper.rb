# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_game
    controller.send :current_game
  end
end
