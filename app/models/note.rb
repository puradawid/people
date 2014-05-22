class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :text, type: String
  field :open, type: Mongoid::Boolean, default: true

  belongs_to :project
  belongs_to :user

  validates :text, presence: true

  scope :open_notes, -> { where(open: true) }
  scope :closed_notes, -> { where(open: false) }

end
