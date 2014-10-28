class GravatarDownloader

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def call!
    user.remote_gravatar_url = users_gravatar_url
    user.save
  end

  private

  def users_gravatar_url
    "https://www.gravatar.com/avatar/#{gravatar_id}?size=#{gravatar_size}"
  end

  def gravatar_id
    Digest::MD5.hexdigest(user_email)
  end

  def gravatar_size
    100
  end

  def user_email
    user.email.downcase
  end
end
