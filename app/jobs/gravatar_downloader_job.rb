class GravatarDownloaderJob
  include SuckerPunch::Job

  def perform(user_id)
    user = User.find(user_id)
    unless GravatarDownloader.new(user).call!
      print "Failed to fetch gravatar for user #{user_id}"
    end
  end
end
