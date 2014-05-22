class HistoryTracker
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
end
