class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :set_colour
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

  def hsv_to_rgb(h, s, v)
    h_i = (h * 6).to_i
    f = h * 6 - h_i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)
    case h_i
    when 0 then r, g, b = v, t, p
    when 1 then r, g, b = q, v, p
    when 2 then r, g, b = p, v, t
    when 3 then r, g, b = p, q, v
    when 4 then r, g, b = t, p, v
    when 5 then r, g, b = v, p, q
    end
    [r, g, b].map { |color| (color * 256).to_i.to_s(16) }
  end

  def set_colour
    golden_ratio_conjugate = 0.618033988749895
    h = rand
    h += golden_ratio_conjugate
    h %= 1
    self.colour ||= "#" + hsv_to_rgb(h, 0.5, 0.95).join
  end
end
