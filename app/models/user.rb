class User
  include Mongoid::Document
  devise :database_authenticatable, :registerable,
         :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :github]

  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :encrypted_password
  field :sign_in_count, type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at, type: Time
  field :current_sign_in_ip
  field :last_sign_in_ip
  field :team_join_time, type: DateTime
  field :oauth_token
  field :refresh_token
  field :oauth_expires_at, type: DateTime

  field :first_name
  field :last_name
  field :email
  field :gh_nick
  field :skype
  field :employment, type: Integer, default: 0
  field :phone
  field :archived, type: Mongoid::Boolean, default: false
  field :available, type: Mongoid::Boolean, default: true
  field :available_since, type: Date
  field :without_gh, type: Mongoid::Boolean, default: false
  field :uid, type: String
  field :user_notes, type: String

  mount_uploader :gravatar, GravatarUploader

  index({ email: 1, deleted_at: 1 })

  has_many :memberships, dependent: :destroy
  has_many :notes
  has_many :positions
  belongs_to :admin_role
  belongs_to :contract_type
  belongs_to :location
  belongs_to :team, inverse_of: :user
  belongs_to :leader_team, class_name: 'Team', inverse_of: :leader
  belongs_to :primary_role, class_name: 'Role'
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :abilities

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :employment, inclusion: { in: 0..200, message: 'must be between 0-200' }
  validates :phone, phone_number: true, length: { maximum: 16 }, allow_blank: true
  validates :archived, inclusion: { in: [true, false] }

  scope :by_name, -> { asc(:first_name, :last_name) }
  scope :by_last_name, -> { asc(:last_name, :first_name) }
  scope :available, -> { where(available: true) }
  scope :active, -> { where(archived: false) }
  scope :technical, -> { where(:primary_role.in => Role.technical.pluck(:id)) }
  scope :technical_active, -> { where(archived: false, available: true) }
  scope :roles, -> (roles) { where(:primary_role.in => roles) }
  scope :contract_users, ->(contract_type) {
    ContractType.where(name: contract_type).first.try(:users)
  }
  scope :without_team, -> { where(team: nil) }
  scope :in_a_project_for_over, lambda { |time|
    project_ids = Project.where(potential: false, archived: false).only(:_id).map(&:_id)
    user_ids = Membership.unfinished.where(:starts_at.lt => time.try(:ago)).in(project_id: project_ids)
      .only(:user_id).map(&:user_id)
    User.in(_id: user_ids)
  }

  before_save :end_memberships
  before_update :save_team_join_time

  def self.cache_key
    max(:updated_at)
  end

  def github_connected?
    gh_nick.present? || without_gh == true
  end

  def admin?
    admin_role.present?
  end

  def has_current_projects?
    current_memberships.present?
  end

  def has_next_projects?
    next_memberships.present?
  end

  def has_potential_projects?
    potential_memberships.present?
  end

  def last_membership
    without_date = user_membership_repository.current.without_end_date.items
    return without_date.last if without_date.present?
    user_membership_repository.current.with_end_date.items.asc(:ends_at).last
  end

  def next_memberships
    @next_memberships ||= user_membership_repository.next.items.asc(:starts_at)
  end

  def potential_memberships
    @potential_memberships ||= user_membership_repository.potential.not_ended.items
  end

  def end_memberships
    memberships.each(&:end_now!) if archived_change && archived_change.last
  end

  def booked_memberships
    @booked_memberships ||= user_membership_repository
      .currently_booked
      .items
      .asc(:ends_at,
           :starts_at)
  end

  def current_project
    memberships.active.current_active.present? ? memberships.active.current_active.first.project : nil
  end

  def current_memberships
    @current_memberships ||= user_membership_repository.current.items.asc(:ends_at)
  end

  def user_membership_repository
    @user_membership_repository ||= UserMembershipRepository.new(self)
  end

  private

  def save_team_join_time
    if team_id_changed?
      team_join_val = team_id.present? ? DateTime.now : nil
      assign_attributes(team_join_time: team_join_val)
    end
  end

  def assign_abilities
    if @abilities_list.present?
      @abilities_list.reject!(&:empty?)
      self.abilities = @abilities_list.map { |name| Ability.find_or_initialize_by(name: name) }
    end
  end

  def map_projects(membership)
    membership.map { |c_ms| { project: c_ms.project, billable: c_ms.billable, membership: c_ms } }
  end
end
