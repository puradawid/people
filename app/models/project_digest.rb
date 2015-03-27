class ProjectDigest
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  class << self
    def ending_in_a_week
      Project.active.between(end_at: (1.week.from_now - 1.day)..1.week.from_now)
    end

    def ending_or_starting_in(days)
      Project.any_of(ProjectDigest.ending_in(days).selector, ProjectDigest.starting_in(days).selector)
    end

    def three_months_old
      Project.nonpotential.select{ |p| p.nonpotential_switch.to_date == 3.months.ago.to_date }
    end

    def ending_in(days)
      Project.between(end_at: Time.now..days.days.from_now)
    end

    def starting_in(days)
      Project.between(kickoff: Time.now..days.days.from_now)
    end

    def starting_tommorow
      Project.potential.between(kickoff: Time.now..1.day.from_now)
    end

    def upcoming_changes(days)
      projects = MembershipsRepository.new.upcoming_changes(days).map(&:project)
      projects << ProjectDigest.ending_or_starting_in(days).to_a
      projects.uniq.flatten
    end
  end

  def starting_in?(days)
    Project.starting_in(days).where(id: id).exists?
  end

  def ending_in?(days)
    Project.ending_in(days).where(id: id).exists?
  end

  def leaving_memberships(days)
    project.memberships.between(ends_at: Time.now..days.days.from_now)
  end

  def joining_memberships(days)
    project.memberships.between(starts_at: Time.now..days.days.from_now)
  end
end
