class HipChat::MessageBuilder
  def self.membership_added_message(membership)
    "#{membership.user.first_name} #{membership.user.last_name} "\
    "added to project \"#{membership.project.name}\" "\
    "from #{membership.starts_at.strftime('%d %b %Y')} "\
    "to #{membership.ends_at.strftime('%d %b %Y')} "\
    "as #{membership.role.name} (billable: #{membership.billable})"
  end

  def self.membership_removed_message(membership)
    "#{membership.user.first_name} #{membership.user.last_name} "\
    "removed from project \"#{membership.project.name}\" "\
  end
end
