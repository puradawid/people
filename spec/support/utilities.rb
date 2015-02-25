include ApplicationHelper

def sign_in(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(
    :google_oauth2,
    info: {
     first_name: user.first_name,
     last_name: user.last_name,
     email: user.email
    },
    extra: { raw_info: { hd: 'example.com' } },
    credentials: {
     oauth_token: 123,
     refresh_token: 456,
     oauth_expires_at: Time.now + 1.hour
    })
  visit new_user_session_path
  click_link_or_button 'Sign up with Google'
end

def selectize_click(id)
  selectize_within(id) do
    first('div.selectize-input').click
  end
end

def select_option(id, text)
  selectize_within(id) do
    first('div.selectize-input').click
    find('div.option', text: text).click
  end
end

def set_text(id, text)
  selectize_within(id) do
    first('div.selectize-input input').set(text)
  end
end

def selectize_within(id)
  type =
    if all(:xpath, "//select[@name='#{id}']/..").present?
      'select'
    else
      'input'
    end

  within(:xpath, "//#{type}[@name='#{id}']/..") do
    yield if block_given?
  end
end
