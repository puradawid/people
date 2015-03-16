Mongoid::Userstamp.config do |c|
  c.user_reader = :current_user
  c.created_name = :created_by
  c.updated_name = :updated_by
end
