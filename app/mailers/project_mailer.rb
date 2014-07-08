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
end
