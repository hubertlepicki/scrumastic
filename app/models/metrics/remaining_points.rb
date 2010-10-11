module Metrics
  class RemainingPoints
    include BasicMetric
    def self.log
      Project.all.each do |project|
        record = RemainingPoints.find_or_initialize_by(date: Time.zone.now.to_date, project_id: project.id)
        record.value = project.reload.user_stories.remaining.collect {|story| story.story_points}.sum
        record.save!
      end
    end
  end
end

