class Ability
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :users

  def self.ordered_by_user_abilities(user)
    ability_ids = user.ability_ids
    not_found_index = ability_ids.count + 1
    scoped.sort_by { |sa| ability_ids.index(sa.id) || not_found_index }
  end

  def to_s
    name
  end
end
