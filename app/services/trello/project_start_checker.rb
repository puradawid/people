module Trello
  class ProjectStartChecker < ProjectChecker
    def run!
      cards.each do |card|
        card_label_names(card).each do |label|
          create_membership_for_user(user_from_card(card), label)
        end
      end
    end

    private

    def card_label_names(card)
      card.card_labels.map { |label| label['name'] }
    end

    def create_membership_for_user(user, project_name)
      UserMembershipRepository.new(user).create(
        project: project_from_label(project_name),
        starts_at: Date.yesterday,
        role: user.primary_role,
        billable: false
      )
    end

    def project_from_label(label)
      ProjectsRepository.new.find_or_create_by_name label
    end
  end
end
