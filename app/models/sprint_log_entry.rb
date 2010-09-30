# encoding: UTF-8

# Single log entry for given day and sprint. Provides info on
# how much effort is left, how much was done.
# Used to generate burn down charts
class SprintLogEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :date, type: String
  field :total_points, type: Float
  field :remaining_points, type: Float
  field :velocity, type: Float

  belongs_to_related :sprint

  def initialize(args={})
    super(args)
    self.total_points ||= 0.0
    self.remaining_points ||= 0.0
    self.velocity ||= 0.0
  end

  def self.find_or_new(s_id, for_date)
    entry = SprintLogEntry.find(:first, conditions: {sprint_id: s_id, date: for_date.to_s})
    entry = SprintLogEntry.new(sprint_id: s_id, date: for_date.to_s) if entry.nil?
    entry
  end
 
  def self.update_now
    Sprint.find( :all,
                 :conditions =>
                 { :start_date => {"$lte" => Time.zone.now.utc },
                   :end_date => {"$gte" => Time.zone.now.utc } }).each do |s|
                     s.log
                   end
  end
end
