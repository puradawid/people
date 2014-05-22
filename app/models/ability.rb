class Ability
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :users

  default_scope asc(:name)

  def to_s
    name
  end
end
