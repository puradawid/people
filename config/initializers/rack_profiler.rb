if %w(development staging).include?(Rails.env)
  require 'rack-mini-profiler'
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
