require 'spec_helper'

describe TimeLogEntry do

  before :each do
    @user = User.create!(valid_user_attributes)
    @project = Project.create!(valid_project_attributes)
    @sprint = Sprint.create!(project: @project, start_date: 2.days.ago)
  end

  it "should be possible to create" do
    TimeLogEntry.create!(user: @user, project: @project, sprint: @sprint)    
  end

  it "should save creation date" do
    TimeLogEntry.create(user: @user, project: @project, sprint: @sprint).created_at.should_not be_nil
  end

  it "should require user" do
    TimeLogEntry.new(project: @project, sprint: @sprint).should_not be_valid
  end


  it "should require project" do
    TimeLogEntry.new(user: @user, sprint: @sprint).should_not be_valid
  end

  it "should require sprint" do
    TimeLogEntry.new(user: @user, project: @project).should_not be_valid
  end

  it "should be in relation with user story" do
    entry = TimeLogEntry.create!(user: @user, project: @project, sprint: @sprint)
    user_story = UserStory.create!(sprint: @sprint, who: "Me", what: "test", project: @project)
    entry.user_story = user_story
    entry.save!
    user_story.time_log_entries.should include(entry)
  end

  it "shoul be nullified when removing associated user story" do
    entry = TimeLogEntry.create!(user: @user, project: @project, sprint: @sprint)
    user_story = UserStory.create!(sprint: @sprint, who: "Me", what: "test", project: @project)
    entry.user_story = user_story
    entry.save!
    user_story.destroy
    TimeLogEntry.count.should eql(1)
    entry.reload.user_story.should be_nil
  end

  it "should be current if just created" do
    entry = TimeLogEntry.create!(user: @user, project: @project, sprint: @sprint)
    entry.should be_current
    @user.current_time_log_entry(@project).should eql(entry)
  end

  it "should be possible to close this time log entry"

  it "should count time on closing"

  it "should be closed automatically when starting new time log entry"

  it "should switch current time log entry to this newly created one"

  it "should verify that time log entries do not overlap"
end

