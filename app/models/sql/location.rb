class Sql::Location < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :users

  def to_s
    name
  end
end
