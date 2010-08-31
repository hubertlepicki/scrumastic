# Validates that start and end dates don't overlap with other sprints
# and that these are in proper order (start_date < end_date).
# Sets sprint.errors hash with proper error message and prevents
# record from saving
class NotOverlappingValidator < ActiveModel::Validator

    def validate(record)
      if record.errors[:end_date].empty?
        record.errors.add :end_date, :greater_than_start_date unless record.start_date < record.end_date
        record.errors.add(:end_date, :cannot_overlap) unless not_overlaps_with?(record, record.end_date)
      end

      if record.errors[:start_date].empty?
        record.errors.add(:start_date, :cannot_overlap) unless not_overlaps_with?(record, record.start_date)
      end

      unless not_contains_within_other?(record)
        record.errors.add(:start_date, :cannot_overlap) unless !record.errors[:start_date].empty?
        record.errors.add(:end_date, :cannot_overlap) unless !record.errors[:end_date].empty?
      end

    end

    private

    def not_overlaps_with?(record, date)
      record.project.sprints.find(:all,
        :conditions => {
          "start_date" => {"$lte" => date}, 
          "end_date"   => {"$gte" => date},
          "_id"        => {"$ne" => record.id}
        }
      ).count == 0
    end

    def not_contains_within_other?(record)
      record.project.sprints.find(:all,
        :conditions => {
          "start_date" => {"$gte" => record.start_date}, 
          "end_date"   => {"$lte" => record.end_date},
          "_id"        => {"$ne" => record.id}
        }
      ).count == 0
    end
end
