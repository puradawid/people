class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::History::Trackable
  include Project::UserAvailability

  after_save :check_potential

  SOON_END = 1.week

  field :name
  field :slug
  field :end_at, type: Time
  field :archived, type: Mongoid::Boolean, default: false
  field :potential, type: Mongoid::Boolean, default: false
  field :kickoff, type: Date

  has_many :memberships, dependent: :destroy
  has_many :notes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, allow_blank: true, allow_nil: true, format: { with: /\A[a-z]+\Z/ }
  validates :archived, inclusion: { in: [true, false] }
  validates :potential, inclusion: { in: [true, false] }

  scope :active, -> { where(archived: false) }
  scope :nonpotential, -> { active.where(potential: false) }
  scope :potential, -> { active.where(potential: true) }
  scope :ending_in_a_week, -> { active.between(end_at: (SOON_END.from_now - 1.day)..SOON_END.from_now) }
  scope :ending_soon, -> { active.between(end_at: Time.now..SOON_END.from_now) }
  scope :starting_tomorrow, -> { potential.between(kickoff: Time.now..1.day.from_now) }

  track_history on: [:archived, :potential], version_field: :version, track_create: true, track_update: true

  def to_s
    name
  end

  def api_slug
    slug.blank? ? name.try(:delete, '^a-zA-Z').try(:downcase) : slug
  end

  def pm
    pm_membership = memberships.with_role(Role.pm).select{ |m| m.active? }.first
    pm_membership.try(:user)
  end

  def self.three_months_old
    Project.nonpotential.select{ |p| p.nonpotential_switch.to_date == 3.months.ago.to_date }
  end

  def nonpotential_switch
    last_track = history_tracks.select do |h|
      h.modified && h.modified['potential'] == false
    end.last

    last_track.present? ? last_track.created_at : self.created_at
  end

  def self.by_name
    all.sort_by{ |p| p.name.downcase }
  end

  private

  def check_potential
    if potential_change == [true, false]
      set_proper_membership_dates
    end
  end

  def set_proper_membership_dates
    memberships.each do |membership|
      if membership.ends_at && membership.ends_at < Time.now
        membership.destroy
      else
        membership.update(starts_at: Time.now)
      end
    end
  end
end
