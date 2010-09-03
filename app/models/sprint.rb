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
  referenced_in :time_log_entry  

  validates_presence_of :project_id, :start_date, :end_date, :name
  validates_uniqueness_of :name, scope: :project_id
  validates_with NotOverlappingValidator, :if => Proc.new {|s| s.project != nil && 
                                                               s.start_date && 
                                                               s.end_date }

  # Custom constructor, adds default values to attributes
  def initialize(args={})
    super(args)

    if project != nil # beware of association proxy, it's not nil but behaves like one
      self.name       ||= "Sprint #{project.sprints.count + 1}" if name.blank?
      self.start_date ||= nearest_monday(max_sprint_end_date || Time.zone.now.to_date)
      self.end_date   ||= start_date + 11.days
    end
  end

  # Removes sprint and moves all user stories back to the backlog
  def destroy(force = false)
    if !force && !user_stories.empty?
      return false
    end
    super()
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

  def is_current?
    (start_date <= Time.zone.now) && (Time.zone.now <= end_date)
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

end
