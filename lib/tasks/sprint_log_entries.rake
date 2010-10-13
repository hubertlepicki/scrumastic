namespace :sprint_log_entries do
  desc "Updates history for log entries, used to generate charts"
  task :update_now => :environment do
    SprintLogEntry.update_now
    Metrics::RemainingPoints.log
    Metrics::ProjectSize.log
    Metrics::CodeComplexity.log
  end
end
