module Trello
  class ProjectEndChecker < ProjectChecker
    def run!
      cards_without_labels.each do |card|
        end_user_memberships user_from_card(card)
      end
    end

    private

    def cards_without_labels
      cards.select { |card| card.card_labels.empty? }
    end

    def end_user_memberships(user)
      memberships = UserMembershipRepository.new(user).without_end_date.items
      memberships.each do |membership|
        membership.update_attribute :ends_at, Date.yesterday
      end
    end
  end
end
