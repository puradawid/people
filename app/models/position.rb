class Position
  include Mongoid::Document
  include Mongoid::Timestamps

  field :starts_at, type: Date

  belongs_to :user, index: true
  belongs_to :role

  validates :user, presence: true
  validates :role, presence: true
  validates :starts_at, presence: true
  validates_with Position::ChronologyValidator
  validates_with Position::RoleValidator

  default_scope -> { asc(:starts_at) }

  def <=>(other)
    [user.last_name, user.first_name, starts_at] <=> [other.user.last_name,
                                                      other.user.first_name, other.starts_at]
  end
end
