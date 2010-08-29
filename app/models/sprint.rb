# encoding: UTF-8

# Sprint is timeboxed iteration of a given project
class Sprint
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :start_date, type: Time
  field :end_date, type: Time
  field :goal, type: String

  belongs_to_related :project
  has_many_related :user_stories
  has_many_related :sprint_log_entries
  
  validates_presence_of :project_id, :start_date, :end_date, :name
  validates_uniqueness_of :name, scope: :project_id
  validate :proper_dates

  # Custom constructor, adds default values to attributes
  def initialize(args={})
    super(args)

    if self.project != nil # beware of association proxy, it's not nil but behaves like one
      self.name ||= "Sprint #{self.project.sprints.count + 1}" if self.name.blank?
      self.start_date ||= nearest_monday(max_sprint_end_date || Time.zone.now.to_date)
      self.end_date ||= self.start_date + 11.days
    end
  end

  # Removes sprint and moves all user stories back to the backlog
  def destroy
    user_stories.each do |story|
      story.move_to_backlog!
    end
    super
  end

  def formatted_end_date=(date)
    self.end_date = Time.parse(date)
  end

  def formatted_start_date=(date)
    self.start_date = Time.parse(date)
  end

  def formatted_end_date
    end_date ? end_date.strftime("%d/%m/%Y") : ""
  end

  def formatted_start_date
    start_date ? start_date.strftime("%d/%m/%Y") : ""
  end

  # Create or update log entries for given sprint if it's current
  # (start_date <= now <= end_date).
  def log
    log_entry = SprintLogEntry.find_or_new(id, Time.zone.now.to_date)
    log_entry.total_points = log_entry.remaining_points = 0

    user_stories.each do |story|
      log_entry.total_points += story.story_points.to_f
      if story.state == "open" || story.state == "assigned"
        log_entry.remaining_points += story.story_points.to_f
      end
    end
    log_entry.save
  end

#  def to_json
#    super(methods: :sprint_log_entries)
#  end

  private

  # Finds what is the end date of last sprint created for this project
  # Used to figure out what's most convinient start date for newly created sprint
  def max_sprint_end_date
    s = project.sprints.find(:first, conditions: {}, sort: [:end_date, :desc])
    return s.end_date if s
    return nil
  end

  # Returns nearest monday in future from given date
  def nearest_monday(from_date)
    return from_date if from_date.monday?
    return from_date.next_week
  end

  # Validates that start and end dates don't overlap with other sprints
  # and that these are in proper order (start_date < end_date).
  # Sets sprint.errors hash with proper error message and prevents
  # record from saving
  def proper_dates
    if self.project != nil && self.start_date && self.end_date # otherwise validates_presence_of will do the work
      errors.add :end_date, "must be greater than start date" unless !errors[:end_date].empty? || (self.start_date < self.end_date)

      errors.add(:start_date, "cannot overlap with other sprints") unless !errors[:start_date].empty? || (self.project.sprints.find(:all,
        :conditions => {
          "start_date" => {"$lte" => self.start_date}, "end_date" => {"$gte" => self.start_date},
          "_id" => {"$ne" => self.id}
        }
      ).count == 0)

      errors.add(:end_date, "cannot overlap with other sprints") unless !errors[:end_date].empty? || (self.project.sprints.find(:all,
        :conditions => {
          "start_date" => {"$lte" => self.end_date}, "end_date" => {"$gte" => self.end_date},
          "_id" => {"$ne" => self.id}
        }
      ).count == 0)
      
      unless self.project.sprints.find(:all,
          :conditions => {
            "start_date" => {"$gte" => self.start_date}, "end_date" => {"$lte" => self.end_date},
            "_id" => {"$ne" => self.id}
          }
        ).count == 0
        errors.add(:start_date, "cannot overlap with other sprints") unless !errors[:start_date].empty?
        errors.add(:end_date, "cannot overlap with other sprints") unless !errors[:end_date].empty?
      end
    end
  end
end
