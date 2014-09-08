class Membership
  include Mongoid::Document
  include Mongoid::Timestamps
  include Membership::UserAvailability

  field :starts_at, type: Time
  field :ends_at, type: Time
  field :billable, type: Mongoid::Boolean
  field :project_archived, type: Mongoid::Boolean, default: false
  field :project_potential, type: Mongoid::Boolean, default: true
  field :stays, type: Mongoid::Boolean, default: false

  belongs_to :user
  belongs_to :project
  belongs_to :role

  validates :user, presence: true
  validates :project, presence: true
  validates :role, presence: true
  validates :starts_at, presence: true
  validates :billable, inclusion: { in: [true, false] }

  validate :validate_starts_at_ends_at
  validate :validate_duplicate_project

  after_save :check_fields

  after_create :notify_added
  after_update :notify_updated
  before_destroy :notify_removed

  scope :active, -> { where(project_potential: false, project_archived: false) }
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
  scope :only_active, -> { where(project_potential: false, project_archived: false).desc('starts_at').limit(3) }
  scope :leaving, ->(days) { between(ends_at: Time.now..days.days.from_now) }
  scope :joining, ->(days) { between(starts_at: Time.now..days.days.from_now) }
  scope :upcoming_changes, lambda { |days|
    any_of(leaving(days).selector, joining(days).selector)
  }

  %w(user project role).each do |model|
    original_model = "original_#{model}"
    alias_method original_model, model

    define_method(model) do
      model.capitalize.constantize.unscoped { send original_model }
    end
  end

  def started?
    starts_at < Time.now
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

  def ends_at=(new_date)
    if new_date.present?
      ends_at_time = Time.zone.parse(new_date.to_s)
      ends_at_time = ends_at_time.end_of_day - 1.second if ends_at_time == ends_at_time.beginning_of_day
      write_attribute(:ends_at, ends_at_time)
    else
      write_attribute(:ends_at, nil)
    end
  end

  def starts_at=(new_date)
    if new_date.present?
      starts_at_time = Time.zone.parse(new_date.to_s)
      if starts_at? && starts_at_time == starts_at.beginning_of_day
        write_attribute(:starts_at, starts_at)
      else
        write_attribute(:starts_at, starts_at_time)
      end
    end
  end

  def end_now!
    update(ends_at: Time.now)
  end

  private

  def check_fields
    if project_potential != project.potential || project_archived != project.archived
      self.update(project_potential: project.potential, project_archived: project.archived)
    end
  end

  def notify_added
    if AppConfig.hipchat.active && active?
      msg = HipChat::MessageBuilder.membership_added_message(self)
      hipchat_notify(msg)
    end
  end

  def notify_removed
    if AppConfig.hipchat.active && active?
      msg = HipChat::MessageBuilder.membership_removed_message(self)
      hipchat_notify(msg)
    end
  end

  def notify_updated
    if AppConfig.hipchat.active && persisted? && active?
      msg = HipChat::MessageBuilder.membership_updated_message(self, changes)
      hipchat_notify(msg)
    end
  end

  def hipchat_notify(msg)
    HipChat::Notifier.new.send_notification(msg)
  end

  def validate_starts_at_ends_at
    if starts_at.present? && ends_at.present? && starts_at > ends_at
      errors.add(:ends_at, "can't be before starts_at date")
    end
  end

  def validate_duplicate_project
    memberships = Membership.with_user(user).not_in(:_id => [id]).where(project_id: project.try(:id))
    if ends_at.present?
      duplicate = memberships.or({ :starts_at.lte => ends_at, :ends_at.gte => starts_at }, { :starts_at.lte => ends_at, :ends_at => nil })
    else
      duplicate = memberships.or({ ends_at: nil }, { :ends_at.gte => starts_at })
    end

    errors.add(:project, "user is not available at given time for this project") if duplicate.exists?
  end
end
