module Metrics
  class CodeComplexity
    include BasicMetric
    def self.log
      Project.all.each do |project|
        record = CodeComplexity.find_or_initialize_by(date: Time.zone.now.to_date, project_id: project.id)
        if !project.application_regexp.blank? && project.repository.update
          files = Dir.glob("#{project.repository.path}/#{project.application_regexp}").join(' ')
          project_size = Dir.glob("#{project.repository.path}/#{project.application_regexp}").collect do |f|
                           `cat #{f} | wc -l`.to_i
                         end.sum.to_f    
          command = "cd #{project.repository.path} && metric_abc #{files}"
          output = `#{command}`
          record.value = (output.split("\n").collect{|l| Math.exp(l.split(": ").last.to_f/10.0) }.sum) / project_size
          puts record.inspect
          record.save!
        end
      end
    end
  end
end

