require 'trello'

Trello.configure do |config|
  config.developer_public_key = AppConfig.trello.developer_public_key
  config.member_token = AppConfig.trello.member_token
end
