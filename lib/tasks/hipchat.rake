namespace :hipchat do
  task daily_digest: :environment do
    HipChat::DailyDigest.new.deliver
  end
end

