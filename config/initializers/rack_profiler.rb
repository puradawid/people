if %w(development stagint).include?(Rails.env)
  require 'rack-mini-profiler'
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
