class AvailabilityChecker
  def initialize(user)
    @user = user
  end

  def run!
    find_memberships_gaps
    @user.update_attributes(available: available?, available_since: available_since)
  end

  private

  def available?
    free_right_now? ||
      has_no_memberships? ||
      has_only_memberships_with_end_date? ||
      has_memberships_with_gaps?
  end

  def available_since
    return unless available?
    return Date.today if free_right_now? || has_no_memberships?

    if has_memberships_with_gaps?
      first_gap_in_memberships
    else
      memberships.last.try(:ends_at).try(:to_date) + 1
    end
  end

  def find_memberships_gaps
    @memberships_with_gaps = []
    memberships_dates = memberships
      .reorder(starts_at: :asc)
      .map{ |membership| { starts: membership.starts_at, ends: membership.ends_at } }

    memberships_dates.each_with_index do |range, i|
      break if range[:ends].nil?
      break if i == memberships_dates.size - 1 # skip last run

      ends_with_buffer = range[:ends] + 1
      next_starts = memberships_dates[i + 1][:starts]

      if ends_with_buffer < next_starts
        @memberships_with_gaps << range
      end
    end
  end

  def has_no_memberships?
    memberships.empty?
  end

  def free_right_now?
    return true if has_no_memberships?

    memberships.reorder(starts_at: :asc).first.starts_at > Date.today
  end

  def has_only_memberships_with_end_date?
    current_memberships_without_end_date.blank?
  end

  def has_memberships_with_gaps?
    @memberships_with_gaps.any?
  end

  def first_gap_in_memberships
    @memberships_with_gaps.first[:ends] + 1
  end

  def current_memberships_without_end_date
    @current_memberships_without_end_date ||= memberships.where(ends_at: nil)
  end

  def current_memberships
    @current_memberships ||= @user.current_memberships.asc(:ends_at)
  end

  def memberships
    @user.memberships.for_availability
  end
end
