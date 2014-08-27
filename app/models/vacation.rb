class Vacation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :starts_at, type: Date
  field :ends_at, type: Date

  belongs_to :user

  validates :starts_at, :ends_at, presence: true

  def date_range
    range = "#{starts_at.to_date}... #{ends_at.to_date}"
  end
end
