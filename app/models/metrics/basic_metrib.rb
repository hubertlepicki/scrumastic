module Metrics
  module BasicMetric
    def self.included(base)
      base.send(:include, Mongoid::Document)
      base.send(:include, Mongoid::Timestamps)

      base.send(:field, :value, type: Float, default: 0.0)
      base.send(:field, :date, type: Time)
      base.send(:referenced_in, :project)

      base.send(:validates_presence_of, :date, :value, :project)
    end
  end
end
