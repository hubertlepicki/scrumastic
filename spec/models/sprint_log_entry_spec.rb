require 'spec_helper'

describe SprintLogEntry do

  before :each do
    @admin = User.create!(valid_user_attributes)
    @project = Project.create!(valid_project_attributes)
    @sprint = Sprint.create!(project: @project, start_date: 2.days.ago, end_date: 3.days.from_now)
  end

  it "should create initial log entry for a day" do
    @sprint.log
    @log = SprintLogEntry.first
    @log.total_points.should eql(0.0)
    @log.remaining_points.should eql(0.0)
    @log.velocity.should eql(0.0)
  end

  it "should update log entries during the day" do
    @sprint.log
    s1 = UserStory.create!( who: "registered user", what: "play",
                            reason: "win cash", project: @project,
                            story_points: 8.0, sprint: @sprint )
    s2 = UserStory.create!( who: "registered user", what: "play",
                            reason: "win cash", project: @project,
                            story_points: 2.0, sprint: @sprint )
    
    @sprint.log
    @log = SprintLogEntry.first
    @log.total_points.should eql(10.0)
    @log.remaining_points.should eql(10.0)
    @log.velocity.should eql(0.0)
    s2.update_attributes state: "resolved"
    @sprint.log
    @log = @log.reload
    @log.total_points.should eql(10.0)
    @log.remaining_points.should eql(8.0)
    @log.velocity.should eql(2.0)
    s1.update_attributes state: "closed"
    @sprint.log
    @log = @log.reload
    @log.total_points.should eql(10.0)
    @log.remaining_points.should eql(0.0)
    @log.velocity.should eql(10.0)
  end
end

describe UserStory, "logging for backlog" do
  before(:each) do
    @admin = User.create!(valid_user_attributes)
    @project = Project.create!(valid_project_attributes)
    @current_sprint =  Sprint.create(project: @project, start_date: 1.day.ago, end_date: 11.days.from_now)
    @future_sprint =  Sprint.create(project: @project, start_date: 1.day.from_now, end_date: 11.days.from_now)
    @past_sprint =  Sprint.create(project: @project, start_date: 11.days.ago, end_date: 1.day.ago)

    @story1 = UserStory.create!( who: "registered user", what: "play",
                                 reason: "win cash", project: @project,
                                 sprint: @current_sprint, story_points: 20.0 )
    @story2 = UserStory.create!( who: "registered user", what: "play",
                                 reason: "win cash", project: @project,
                                 sprint: @current_sprint, story_points: 30.0 )
    @story3 = UserStory.create!( who: "registered user", what: "play",
                                 reason: "win cash", project: @project,
                                 sprint: @future_sprint, story_points: 10.0 )
    @story4 = UserStory.create!( who: "registered user", what: "play",
                                 reason: "win cash", project: @project,
                                 sprint: @past_sprint, story_points: 10.0 )
  end

  it "should create log entry on demand for all open sprints" do
    SprintLogEntry.update_now
    entry = SprintLogEntry.first
    entry.total_points.should eql(50.0)
    entry.remaining_points.should eql(50.0)
    Date.parse(entry.date).should eql(Time.now.to_date)
  end

  it "should update log entry previously created if the same day" do
    SprintLogEntry.update_now
    UserStory.create!( who: "registered user", what: "play",
                       reason: "win cash", project: @project,
                       sprint: @current_sprint, story_points: 20.0 )

    @story2.update_attributes state: "closed"
    SprintLogEntry.update_now
    entry = SprintLogEntry.first
    entry.total_points.should eql(70.0)
    entry.remaining_points.should eql(40.0)
    Date.parse(entry.date).should eql(Time.now.to_date)
  end

  it "should create new log entry when it's different day" do
    SprintLogEntry.update_now
    Timecop.travel 1.day.from_now do
      SprintLogEntry.update_now
      SprintLogEntry.count.should eql(2)
    end
  end

  it "should not create sprint log entries for sprints that are not current" do
    SprintLogEntry.update_now
    Timecop.travel 200.day.from_now do
      SprintLogEntry.update_now
      SprintLogEntry.count.should eql(1)
    end
  end
end
