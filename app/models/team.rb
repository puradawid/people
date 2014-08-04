class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :users, inverse_of: :team
  has_one :leader, class_name: 'User', inverse_of: :leader_team

  accepts_nested_attributes_for :users
end
