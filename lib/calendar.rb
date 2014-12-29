module Calendar
  def initialize_client(user)
    @client = Google::APIClient.new(application_name: 'calendar', application_version: '1.0')
    @client.authorization.access_token = user.oauth_token
    @client.authorization.refresh_token = user.refresh_token
    @client.authorization.client_id = AppConfig.google_client_id
    @client.authorization.client_secret = AppConfig.google_secret
    @service = @client.discovered_api('calendar', 'v3')
  end
end
