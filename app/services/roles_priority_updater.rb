class RolesPriorityUpdater
  attr_reader :sorted_role_ids

  def initialize(params)
    @sorted_role_ids = params
  end

  def call!
    sorted_role_ids.each_with_index do |id, index|
      Role.find(id).set(priority: index + 1)
    end
  end
end
