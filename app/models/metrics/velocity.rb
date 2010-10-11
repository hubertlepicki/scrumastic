module Metrics
  class Velocity
    include Mongoid::Document
    include Mongoid::Timestamps

    field :value, type: Float, default: 0.0
    field :date, type: Time
    referenced_in :project

    validates_presence_of :date, :value, :project
  end
end
