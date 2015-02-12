class AvailabilityChecker
  def initialize(user)
    @user = user
  end

  def run!
    @user.update_attributes(available: available?, available_since: available_since)
  end

  private

  def available?
    has_no_memberships? ||
      has_only_non_billable_memberships? ||
      has_only_memberships_with_end_date? ||
      has_memberships_with_gaps?
  end

  def available_since
    return unless available?

    if current_memberships.billable.present?
      return current_memberships.billable.first.try(:ends_at).try(:to_date)
    end

    Date.today
  end

  def has_no_memberships?
    current_memberships.empty?
  end

  def has_only_non_billable_memberships?
    current_memberships.billable.blank?
  end

  def has_only_memberships_with_end_date?
    current_memberships_without_end.blank?
  end

  def has_memberships_with_gaps?
    memberships_with_gaps = []
    memberships_dates = @user
      .memberships
      .unfinished
      .billable
      .asc(:starts_at)
      .map{ |membership| { starts: membership.starts_at, ends: membership.ends_at } }

    memberships_dates.each_with_index do |range, i|
      break if range[:ends].nil?
      break if i == memberships_dates.size - 1 # skip last run

      ends_with_buffer = range[:ends] + 1
      next_starts = memberships_dates[i + 1][:starts]

      if ends_with_buffer < next_starts
        memberships_with_gaps << range
      end
    end

    memberships_with_gaps.any?
  end

  def current_memberships_without_end
    @current_memberships_without_end ||= @user.memberships.billable.where(ends_at: nil)
  end

  def current_memberships
    @current_memberships ||= @user.current_memberships.asc(:ends_at)
  end
end
