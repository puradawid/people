module Calendar
  def initialize_client(user)
    @client = Google::APIClient.new(application_name: 'calendar', application_version: '1.0')
    @client.authorization.access_token = user.oauth_token
    @client.authorization.refresh_token = user.refresh_token
    @client.authorization.client_id = AppConfig.google_client_id
    @client.authorization.client_secret = AppConfig.google_secret
    @service = @client.discovered_api('calendar', 'v3')
  end

  def import_vacation(user)
    initialize_client(user)
    page_token = nil
    result = @client.execute(api_method: @service.events.list,
                             parameters: { 'calendarId' => AppConfig.calendar_id })

    loop do
      events = result.data.items
      events.each do |e|
        usr = User.find_by(email: e.creator.email)
        if (e.summary =~ /#{AppConfig.calendar_summary_regex}/i) && (e.start.date.to_date >= 2.weeks.ago.to_date) && usr.vacation.nil?
          usr.build_vacation
          usr.vacation.starts_at = e.start.date
          usr.vacation.ends_at = e.end.date.to_date - 1.day
          usr.vacation.eventid = e.id
          usr.vacation.save
        end
      end
      unless (page_token = result.data.next_page_token)
        break
      end
      result = @client.execute(api_method: @service.events.list,
                               parameters: { 'calendarId' => AppConfig.calendar_id, 'pageToken' => page_token })
    end
  end

  def export_vacation(user)
    event = {
      'summary' => "#{user.first_name} #{user.last_name} - vacation",
      'start' => { 'date' => user.vacation.starts_at },
      'end' => { 'date' => user.vacation.ends_at + 1.day }
    }

    initialize_client(user)
    result = @client.execute(
      api_method: @service.events.insert,
      parameters: { 'calendarId' => AppConfig.calendar_id },
      body: JSON.dump(event),
      headers: { 'Content-Type' => 'application/json' })

    user.vacation.update_attributes(eventid: result.data.id)
    user.save
  end

  def update_vacation(user)
    initialize_client(user)
    result = @client.execute(
      api_method: @service.events.get,
      parameters: { 'calendarId' => AppConfig.calendar_id, 'eventId' => user.vacation.eventid })

    event = result.data
    event.start.date = "#{user.vacation.starts_at}"
    event.end.date = "#{user.vacation.ends_at + 1.day}"
    result = @client.execute(
      api_method: @service.events.update,
      parameters: { 'calendarId' => AppConfig.calendar_id, 'eventId' => user.vacation.eventid },
      body: JSON.dump(event),
      headers: { 'Content-Type' => 'application/json' })
  end

  def delete_vacation(user)
    initialize_client(user)
    @client.execute(api_method: @service.events.delete,
                    parameters: { 'calendarId' => AppConfig.calendar_id, 'eventId' => user.vacation.eventid })
  end
end
