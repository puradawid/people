class MembershipEnder
  attr_accessor :membership

  def initialize(membership)
    self.membership = membership
  end

  def call!
    membership.update!(ends_at: Time.now)
  end
end
