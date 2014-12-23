class Sql::AdminRole < ActiveRecord::Base
  has_many :users
end
