class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  has_many :users
  accepts_nested_attributes_for :users
end
