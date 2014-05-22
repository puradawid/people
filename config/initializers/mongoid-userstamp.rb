Mongoid::Userstamp.config do |c|

  c.user_reader = :current_user
  c.user_model = :user

  c.created_column = :created_by
  c.created_accessor = :creator

  c.updated_column = :updated_by
  c.updated_accessor = :updater

end
