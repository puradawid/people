class Role
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Orderable

  after_create :move_to_bottom

  has_many :memberships
  has_many :users
  has_many :positions

  orderable column: :priority
  field :name, type: String
  field :color, type: String
  field :billable, type: Mongoid::Boolean, default: false
  field :technical, type: Mongoid::Boolean, default: false
  field :show_in_team, type: Mongoid::Boolean, default: true

  validates :name, presence: true, uniqueness: true
  validates :billable, inclusion: { in: [true, false] }
  validates :technical, inclusion: { in: [true, false] }

  default_scope asc(:priority)
  scope :billable, where(billable: true)
  scope :non_billable, where(billable: false)
  scope :technical, where(technical: true)

  def to_s
    name
  end

  def self.pm
    where(name: "pm").first_or_create
  end

  def self.by_name
    all.sort_by{ |r| r.name.downcase }
  end
end
