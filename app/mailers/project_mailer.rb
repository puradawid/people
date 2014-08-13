class ProjectMailer < BaseMailer
  def ending_soon(project)
    @project = project
    to = project.pm.try(:email) || [AppConfig.emails.pm]
    mail(to: to, subject: "Your project will end soon.", project: @project)
  end

  def three_months_old(project)
    @project = project
    to = project.pm.try(:email) || [AppConfig.emails.pm], AppConfig.emails.social
    mail(to: to, subject: "#{project.name}, references", project: @project)
  end

  def kickoff_tomorrow(project)
    @project = project
    to = [project.pm.try(:email), AppConfig.emails.pm].compact
    mail(to: to, subject: "#{ project.name } is starting tomorrow", project: @project)
  end

  def upcoming_changes(project, days)
    @project = project
    @days = days
    @memberships_leaving = @project.memberships.leaving(days)
    @memberships_joining = @project.memberships.joining(days)
    to = project.pm.try(:email) || [AppConfig.emails.pm]
    subject = "#{ project.name }: the next #{ days } days"
    mail(to: to, subject: subject, project: @project)
  end
end
