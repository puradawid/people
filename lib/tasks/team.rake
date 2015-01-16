namespace :team do
  desc "Team field setter task"
  task :set_fields => :environment do
    old_objects = Team.or(initials: nil, colour: nil)
    old_objects.each do |old_object|
      old_object.save
    end
  end
end
