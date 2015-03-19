class Membership
  include Mongoid::Document
  include Mongoid::Timestamps
  include Membership::UserAvailability
  include Membership::HipchatNotifications

  field :starts_at, type: Date
  field :ends_at, type: Date
  field :billable, type: Mongoid::Boolean
  field :project_archived, type: Mongoid::Boolean, default: false
  field :project_potential, type: Mongoid::Boolean, default: true
  field :project_internal, type: Mongoid::Boolean, default: true
  field :stays, type: Mongoid::Boolean, default: false
  field :booked, type: Mongoid::Boolean, default: false

  belongs_to :user, index: true, touch: true
  belongs_to :project, index: true
  belongs_to :role

  validates :user, presence: true
  validates :project, presence: true
  validates :role, presence: true
  validates :starts_at, presence: true
  validates :billable, inclusion: { in: [true, false] }

  validate :validate_starts_at_ends_at
  validate :validate_duplicate_project

  after_save :check_fields

  scope :active, -> { where(project_potential: false, project_archived: false) }
  scope :not_archived, -> { where(project_archived: false) }
  scope :potential, -> { where(project_potential: true) }
  scope :with_role, ->(role) { where(role: role) }
  scope :with_user, ->(user) { where(user: user) }
  scope :unfinished, -> { any_of({ ends_at: nil }, { :ends_at.gt => Time.current }) }
  scope :finished, -> { lte(ends_at: Time.current) }
  scope :current_active, -> do
     lt(starts_at: Time.current).or({ ends_at: nil }, { ends_at: { "$gt" => Time.current } })
   end
  scope :ending_soon, -> { between(ends_at: Time.now..1.week.from_now) }
  scope :billable, -> { where(billable: true) }
  scope :without_bookings, -> { where(booked: false) }
  scope :only_active, -> { where(project_potential: false, project_archived: false, booked: false).desc('starts_at').limit(3) }
  scope :leaving, ->(days) { between(ends_at: Time.now..days.days.from_now) }
  scope :joining, ->(days) { between(starts_at: Time.now..days.days.from_now) }
  scope :upcoming_changes, lambda { |days|
    any_of(leaving(days).selector, joining(days).selector)
  }
  scope :by_starts_at, -> { desc(:starts_at) }
  scope :for_availability, -> { unfinished.without_bookings.asc(:ends_at) }

  def started?
    starts_at <= Date.today
  end

  def terminated?
    ends_at.try('<', Time.now) || false
  end

  def active?
    started? && !terminated?
  end

  def potential_start
    (project.kickoff || starts_at).to_date
  end

  def end_now!
    update(ends_at: Date.today)
  end

  private

  def check_fields
    if project_state_changed?
      update(project_potential: project.potential,
        project_archived: project.archived,
        project_internal: project.internal
      )
    end
  end

  def project_state_changed?
    project_potential != project.potential || project_archived != project.archived || project_internal != project.internal
  end

  def validate_starts_at_ends_at
    if starts_at.present? && ends_at.present? && starts_at > ends_at
      errors.add(:ends_at, "can't be before starts_at date")
    end
  end

  def validate_duplicate_project
    MembershipCollision.new(self).call!
  end
end
