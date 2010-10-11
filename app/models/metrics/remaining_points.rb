module Metrics
  class RemainingPoints
    include Mongoid::Document
    include Mongoid::Timestamps

    field :value, type: Float, default: 0.0
    field :date, type: Time
    referenced_in :project

    validates_presence_of :date, :value, :project

    def self.log
      Project.all.each do |project|
        record = RemainingPoints.find_or_initialize_by(date: Time.now.utc.midnight.midnight, project_id: project.id)
        record.value = project.reload.user_stories.remaining.collect {|story| story.story_points}.sum
        record.save!
      end
    end
  end
end

