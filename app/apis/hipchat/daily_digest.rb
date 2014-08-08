class HipChat::DailyDigest
  attr_accessor :ending_projects, :kickoff_soon_projects,
                :beginning_memberships, :ending_memberships

  def initialize
    raise 'HipChat set to inactive in configuration' \
      unless AppConfig.hipchat.active
  end

  def deliver
  end
end
