class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  include InitialsHandler

  before_save :set_color

  field :name
  field :initials
  field :colour

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :users, inverse_of: :team
  has_one :leader, class_name: 'User', inverse_of: :leader_team

  accepts_nested_attributes_for :users

  def set_color
    self.colour ||= AvatarColor.new.as_rgb
  end
end
