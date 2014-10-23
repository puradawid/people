require 'active_support/core_ext'
require 'konf'

rails_env =
  if defined? Rails
    Rails.env
  else
    ENV['RAILS_ENV']
  end

pub_config = (YAML.load(ERB.new(File.read(File.expand_path('../config.yml',     __FILE__))).result)[rails_env] rescue {}) || {}
sec_config = (YAML.load(ERB.new(File.read(File.expand_path('../sec_config.yml', __FILE__))).result)[rails_env] rescue {}) || {}
AppConfig = Konf.new(pub_config.deep_merge(sec_config))

