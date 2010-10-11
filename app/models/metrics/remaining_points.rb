module Metrics
  class RemainingPoints
    include Mongoid::Document
    include Mongoid::Timestamps

    field :metric_value, type: Float, default: 0.0
    field :day, type: Time
    referenced_in :project

    def self.log
      Project.all.each do |project|
        record = RemainingPoints.first(conditions: {day: Time.now.utc.midnight.midnight, project_id: project.id})
        record = RemainingPoints.new(day: Time.now.utc.midnight.midnight, project_id: project.id) if record.nil?
        record.metric_value = project.reload.user_stories.where(state: {"$ne" => "closed"}).collect {|story| story.story_points}.sum
        record.save!
      end
    end
  end
end

