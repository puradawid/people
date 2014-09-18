class ContractType
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, type: String

  index({ deleted_at: 1 })

  validates :name, presence: true, uniqueness: true

  has_many :users

  def to_s
    name
  end
end
