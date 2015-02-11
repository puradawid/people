class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :set_color
  before_save :set_initials

  field :name
  field :initials
  field :colour

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :users, inverse_of: :team
  has_one :leader, class_name: 'User', inverse_of: :leader_team

  accepts_nested_attributes_for :users

  private

  def set_initials
    camel_case = name.underscore.split('_')
    splitted = camel_case.count > 1 ? camel_case : name.split
    self.initials = splitted[0..1].map { |w| w[0] }.join.upcase
  end

  def set_color
    self.colour ||= TeamColor.new.as_rgb
  end
end
