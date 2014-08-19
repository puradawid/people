include ApplicationHelper

def sign_in(user)
  OmniAuth.config.test_mode = true
  Capybara.default_driver = :selenium
  OmniAuth.config.add_mock(:google_oauth2, {
    info: {
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    },
    extra: { raw_info: { hd: 'example.com' }}
  })
  visit new_user_session_path
  click_link_or_button 'Sign up with Google'
end
