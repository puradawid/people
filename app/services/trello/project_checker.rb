module Trello
  class ProjectChecker
    attr_accessor :board, :cards

    def initialize board
      @board = board
      get_cards
    end

    private

    def get_cards
      @cards = board.cards
    end

    def user_from_card(card)
      attrs = {
        first_name: card.name.split[0],
        last_name:  card.name.split[1]
      }
      UserRepository.new.find_by(attrs)
    end
  end
end
