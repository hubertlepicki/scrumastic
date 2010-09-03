class TimeLogEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  referenced_in :sprint
  referenced_in :project
  referenced_in :user
  referenced_in :user_story
  field :number_of_seconds, type: Integer, default: 0
  field :current, type: Boolean, default: true  

  validates_presence_of :sprint, :project, :user
  validates_uniqueness_of :current, :scope => :project_id, :if => Proc.new {|o| o.current == true }

  def nullify
    [:sprint, :user, :user_story].each do |relation|
      begin
        send(relation)
      rescue Mongoid::Errors::DocumentNotFound
        send "#{relation}=", nil
      end
    end
    save
  end
end
