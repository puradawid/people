class Feature
  include Mongoid::Document
  include Mongoid::Timestamps

  extend Flip::Declarable

  strategy Flip::CookieStrategy
  strategy Flip::DatabaseStrategy
  strategy Flip::DeclarationStrategy
  default false

  field :key, type: String
  field :enabled, type: Boolean

  feature :vacations, default: true

end
