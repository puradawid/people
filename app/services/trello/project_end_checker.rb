module Trello
  class ProjectEndChecker
    attr_accessor :board, :cards

    def initialize board
      @board = board
      get_cards
    end

    def run!
      cards_without_labels.each do |card|
        end_user_memberships user_from_card(card)
      end
    end

    private

    def card_label_names(card)
      card.card_labels.map { |label| label['name'] }
    end

    def cards_without_labels
      cards.select { |card| card.card_labels.empty? }
    end

    def end_user_memberships(user)
      memberships = UserMembershipRepository.new(user).without_end_date.items
      memberships.each do |membership|
        membership.update_attribute :ends_at, Date.yesterday
      end
    end

    def get_cards
      @cards = board.cards
    end

    def project_from_label(label)
      ProjectsRepository.new.find_or_create_by_name label
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
