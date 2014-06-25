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

  field :first_name
  field :last_name
  field :email
  field :gh_nick
  field :skype
  field :employment, type: Integer, default: 0
  field :phone
  field :archived, type: Mongoid::Boolean, default: false
  field :available, type: Mongoid::Boolean, default: true
  field :uid, type: String

  has_many :memberships
  has_many :notes
  has_many :positions
  belongs_to :role
  belongs_to :contract_type
  belongs_to :location
  has_and_belongs_to_many :abilities

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :employment, inclusion: { in: 0..200, message: "must be between 0-200" }
  validates :phone, length: { maximum: 16 }, format: { with: %r{\A[+]?\d+(?>[- .]\d+)*\z} }, allow_blank: true
  validates :archived, inclusion: { in: [true, false] }

  scope :by_name, -> { asc(:first_name, :last_name) }
  scope :available, -> { where(available: true) }
  scope :active, -> { where(archived: false) }
  scope :technical_active, -> { where(archived: false, available: true) }
  scope :roles, -> (roles) { where(:role.in => roles) }
  scope :contract_users, ->(contract_type) { where(contract_type_id: ContractType.where(name: contract_type).first.id) }

  before_save :end_memberships
  before_validation :assign_abilities

  def self.create_from_google!(params)
    user = User.where(uid: params['uid']).first
    user = User.where(email: params['info']['email']).first if user.blank?
    if user.present?
      user.update_attributes(uid: params['uid']) if user.uid.blank?
      return user
    end
    fields = %w(first_name last_name email)
    attributes = fields.reduce({}) { |mem, key| mem.merge(key => params['info'][key]) }
    attributes['password'] = Devise.friendly_token[0, 20]
    attributes['uid'] = params['uid']

    User.create!(attributes)
  end

  def self.get_from_api params
    User.where(id: params['id']).first || User.where(email: params['email']).first
  end

  def flat_memberships
    membs_grouped = memberships.group_by { |m| m.project.api_slug }
    membs_grouped.each do |slug, membs|
      membs_grouped[slug] = {
          starts_at: (membs.map(&:starts_at).include?(nil) ? nil : membs.map(&:starts_at).compact.min),
          ends_at: (membs.map(&:ends_at).include?(nil) ? nil : membs.map(&:ends_at).compact.max),
          role: (membs.map { |memb| memb.role.try(:name) }).last
      }
    end
  end

  def github_connected?
    gh_nick.present?
  end

  def potential_projects
    @potential_projects ||= potential_memberships.map { |c_ms| { project: c_ms.project, billable: c_ms.billable, membership: c_ms } }
  end

  def memberships_cached
    @memberships ||= memberships.includes(:project).to_a
  end

  def potential_memberships
    @potential_project_ids ||= Project.where(potential: true).only(:_id).map(&:_id)
    memberships_by_project_ids @potential_project_ids
  end

  def current_projects
    @current_projects ||= current_memberships.map { |c_ms| { project: c_ms.project, billable: c_ms.billable, membership: c_ms } }
  end

  def current_memberships
    @nonpotential_project_ids ||= Project.where(potential: false).only(:_id).map(&:_id)
    memberships_by_project_ids @nonpotential_project_ids
  end

  def last_membership
    without_date = current_memberships.reject(&:ends_at)
    return without_date.last if without_date.present?
    current_memberships.select(&:ends_at).sort_by(&:ends_at).first
  end

  def memberships_by_project_ids(project_ids)
    now = Time.now
    memberships_cached.select { |m| project_ids.include?(m.project_id) && (m.starts_at <= now && (m.ends_at == nil || m.ends_at >= now)) }
  end

  %w(current potential next).each do |type|
    type += "_projects"
    define_method("has_#{type}?") do
      send(type).present?
    end
  end

  def next_memberships
    now = Time.now
    memberships_cached.select { |m| m.starts_at >= now && (m.ends_at == nil || m.ends_at >= now) }
  end

  def next_projects
    @next_projects ||= next_memberships.map { |n_ms| { project: n_ms.project, billable: n_ms.billable, membership: n_ms } }
  end

  def memberships_by_project
    Project.unscoped do
      memberships.includes(:project, :role).group_by(&:project_id).each_with_object({}) do |data, memo|
        memberships = data[1].sort { |m1, m2| m2.starts_at <=> m1.starts_at }
        project = memberships.first.project
        memo[project] = MembershipDecorator.decorate_collection memberships
      end
    end
  end

  def end_memberships
    memberships.each(&:end_now!) if archived_change && archived_change.last
  end

  def admin?
    self.role.try(:admin)
  end

  def self.by_name
    all.sort_by { |u| u.first_name.downcase }
  end

  def abilities_names
    abilities.map(&:name)
  end

  def abilities_names=(abilities_list)
    @abilities_list = abilities_list
  end

  private

  def assign_abilities
    if @abilities_list.present?
      @abilities_list.reject!(&:empty?)
      self.abilities = @abilities_list.map { |name| Ability.find_or_initialize_by(name: name) }
    end
  end
end
