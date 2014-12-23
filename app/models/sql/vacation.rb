class Sql::Vacation < ActiveRecord::Base

  belongs_to :user, inverse_of: :vacation

  validates :starts_at, :ends_at, presence: true

  def date_range
    "#{starts_at.to_date}... #{ends_at.to_date}"
  end
end
