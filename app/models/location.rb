class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, type: String

  validates :name, presence: true, uniqueness: true

  has_many :users

  def to_s
    name
  end
end
