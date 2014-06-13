class Ability
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :users

  def self.ordered_as_user_sort(user)
    user_abilities_count = user.ability_ids.length
    all.sort_by {|sa| user.ability_ids.any? { |a| a == sa.id } ? user.ability_ids.index(sa.id) : user_abilities_count+1 }
  end

  def to_s
    name
  end
end
