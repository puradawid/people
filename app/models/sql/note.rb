class Sql::Note < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates :text, presence: true

  scope :open_notes, -> { where(open: true) }
  scope :closed_notes, -> { where(open: false) }

end
