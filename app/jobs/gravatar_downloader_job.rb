class GravatarDownloaderJob
  include SuckerPunch::Job

  def perform(user_id)
    user = User.find(user_id)
    GravatarDownloader.new(user).call!
  end
end
