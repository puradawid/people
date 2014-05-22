class MoveLocationToModel < Mongoid::Migration
  def self.up
    User.all.each do |user|
      begin
        user_location = Location.find_by(name: user.attributes["location"])
        user.location_id = user_location.id
        user.save
      rescue Mongoid::Errors::DocumentNotFound
        puts "oupst, location not found"
      end
    end
  end

  def self.down
  end
end
