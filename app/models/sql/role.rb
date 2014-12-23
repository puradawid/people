class Sql::Role < ActiveRecord::Base

  has_many :memberships
  has_many :users
  has_many :positions

  acts_as_orderable

  validates :name, presence: true, uniqueness: true
  validates :billable, inclusion: { in: [true, false] }
  validates :technical, inclusion: { in: [true, false] }

  scope :billable, -> { where(billable: true) }
  scope :non_billable, -> { where(billable: false) }
  scope :technical, -> { where(technical: true) }

  def apply_mongo_priority!(priority)
    self.element_order = priority
  end

  def to_s
    name
  end

  def self.pm
    where(name: "pm").first_or_create
  end

  def self.by_name
    all.sort_by{ |r| r.name.downcase }
  end
end
