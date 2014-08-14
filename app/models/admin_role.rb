class AdminRole
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :users

end
