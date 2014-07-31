class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :team_leader_id

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :users
  accepts_nested_attributes_for :users
end
