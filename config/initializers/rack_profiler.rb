if %w(development stagint).include?(Rails.env)
  require 'rack-mini-profiler'
end
