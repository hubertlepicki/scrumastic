class TimeLogEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  referenced_in :project
  referenced_in :user
  referenced_in :user_story
  field :number_of_seconds, type: Integer, default: 0
  field :current, type: Boolean, default: true  

  validates_presence_of :project, :user
  validates_uniqueness_of :current, scope: :project_id, if: Proc.new {|o| o.current == true }
  before_validation :close_current_if_new
  
  def can_edit?(user)
    self.user == user || user.role_in_project(project) == :scrum_master
  end

  def nullify
    [:user, :user_story].each do |relation|
      begin
        send(relation)
      rescue Mongoid::Errors::DocumentNotFound
        send "#{relation}=", nil
      end
    end
    save
  end

  def close
    update_attributes current: false, number_of_seconds: Time.zone.now.to_i - created_at.to_i
  end

  def close_current_if_new
    if new_record? && project && user
      TimeLogEntry.all(conditions: {user_id: user.id, project_id: project.id, current: true}).each do |e|
        e.close
      end
    end
  end

  def formatted_created_at=(time)
    begin
      self.created_at = Time.parse(time)
    rescue ArgumentError
      # silently ignore, use default 
    end
  end

  def formatted_created_at
    (created_at ? created_at : Time.zone.now).strftime("%d/%m/%Y %k:%M:%S")
  end


end
