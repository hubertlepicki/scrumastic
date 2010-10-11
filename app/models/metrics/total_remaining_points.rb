module Metric
  class RemainingPoints
    include Mongoid::Document
    include Mongoid::Timestamps

    key :value, type: Float
    referenced_in :project
  end
end


