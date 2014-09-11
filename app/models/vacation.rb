class Vacation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :starts_at, type: Date
  field :ends_at, type: Date
  field :eventid

  belongs_to :user, inverse_of: :vacation

  validates :starts_at, :ends_at, presence: true

  def date_range
    "#{starts_at.to_date}... #{ends_at.to_date}"
  end
end
