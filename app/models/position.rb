class Position
  include Mongoid::Document
  include Mongoid::Timestamps

  field :starts_at, type: Date

  belongs_to :user
  belongs_to :role

  validates :user, presence: true
  validates :role, presence: true
  validates :starts_at, presence: true
  validate :validate_chronology
  validate :validate_position

  default_scope asc(:starts_at)

  def available_roles
    pos = Role.all.to_a - user.positions.ne(created_at: nil).map(&:role)
    pos << role if created_at
    pos
  end

  def validate_chronology
    positions = user.positions.sort_by!(&:starts_at).map(&:role).map(&:name)
    is_valid = positions == Role.in(name: positions).sort_by(&:priority).map(&:name).reverse!
    errors.add(:starts_at, I18n.t('positions.errors.chronology')) unless is_valid
  end

  def validate_position
    errors.add(:role, I18n.t('positions.errors.role')) unless available_roles.any? { |p| p.name == role.name }
  end

  def self.by_user_name_and_date(positions = all)
    positions.sort_by! { |p| [p.user.first_name, p.user.last_name, p.starts_at] }
  end

end
