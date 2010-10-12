module Metrics
  class ProjectSize
    include BasicMetric
    def self.log
      Project.all.each do |project|
        record = ProjectSize.find_or_initialize_by(date: Time.zone.now.to_date, project_id: project.id)
        if !project.application_regexp.blank? && project.repository.update
          record.value = Dir.glob("#{project.repository.path}/#{project.application_regexp}").collect do |f|
                           `cat #{f} | wc -l`.to_i
                         end.sum       
          record.save!   
        end
      end
    end
  end
end

