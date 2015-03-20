class Ability
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  mount_uploader :icon, IconUploader

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :users

  def to_s
    name
  end
end
