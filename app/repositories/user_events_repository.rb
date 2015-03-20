class UserEventsRepository
  attr_accessor :user_membership_repository

  def initialize(user_membership_repository)
    self.user_membership_repository = user_membership_repository
  end

  def all
    @events ||= user_membership_repository.all.map do |m|
      if m.project.present?
        event = { text: m.project.name, startDate: m.starts_at.to_date }
        event[:endDate] = m.ends_at.to_date if m.ends_at
        event[:user_id] = m.user.id.to_s
        event[:billable] = m.billable
        event
      end
    end
    @events.compact
  end
end
