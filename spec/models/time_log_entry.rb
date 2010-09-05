require 'spec_helper'

describe TimeLogEntry do

  before :each do
    @user = User.create!(valid_user_attributes)
    Timecop.travel(10.minutes.ago) do
      @project = Project.create!(valid_project_attributes)
    end
  end

  it "should be possible to create" do
    TimeLogEntry.create!(user: @user, project: @project)    
  end

  it "should save creation date" do
    TimeLogEntry.create(user: @user, project: @project).created_at.should_not be_nil
  end

  it "should require user" do
    TimeLogEntry.new(project: @project).should_not be_valid
  end


  it "should require project" do
    TimeLogEntry.new(user: @user).should_not be_valid
  end


  it "should be in relation with user story" do
    entry = TimeLogEntry.create!(user: @user, project: @project)
    user_story = UserStory.create!(who: "Me", what: "test", project: @project)
    entry.user_story = user_story
    entry.save!
    user_story.time_log_entries.should include(entry)
  end

  it "shoul be nullified when removing associated user story" do
    entry = TimeLogEntry.create!(user: @user, project: @project)
    user_story = UserStory.create!(who: "Me", what: "test", project: @project)
    entry.user_story = user_story
    entry.save!
    user_story.destroy
    TimeLogEntry.count.should eql(1)
    entry.reload.user_story.should be_nil
  end

  it "should be current if just created" do
    entry = TimeLogEntry.create!(user: @user, project: @project)
    entry.should be_current
    @user.current_time_log_entry(@project).should eql(entry)
  end

  it "should be possible to close this time log entry" do
    entry = TimeLogEntry.create!(user: @user, project: @project)
    @user.current_time_log_entry(@project).close
    entry.reload.should_not be_current
  end

  it "should close current time log entry when creating new one" do
    entry = TimeLogEntry.create!(user: @user, project: @project)
    TimeLogEntry.create(user: @user, project: @project)
    entry.reload.should_not be_current
  end

  it "should count time on closing" do
    entry = nil
    Timecop.travel(2.minutes.ago) do
      entry = TimeLogEntry.create!(user: @user, project: @project)
    end
    entry.close
    entry.number_of_seconds.should > 0
  end

  it "should switch current time log entry to this newly created one" do
    entry = TimeLogEntry.create!(user: @user, project: @project)
    TimeLogEntry.create(user: @user, project: @project).should be_current
  end 

  it "should be possible to override created_at date on creation" do
    entry = TimeLogEntry.create!(user: @user, project: @project, formatted_created_at: "01/01/2001 00:33")
    entry.reload.created_at.should eql(Time.parse("01/01/2001 00:33"))
  end

  it "should verify that time log entries do not overlap" # implement when doing edit

  it "should sum time for given project" do
    entry = nil
    Timecop.travel(2.minutes.ago) do
      TimeLogEntry.create!(user: @user, project: @project)
    end
    Timecop.travel(1.minutes.ago) do
      entry = TimeLogEntry.create!(user: @user, project: @project)
    end
    entry.close
    @project.worked_time.should eql(120) 
  end

  it "should sum time for given project, with time restrictions" do
    entry = nil
    Timecop.travel(3.minutes.ago) do
      TimeLogEntry.create!(user: @user, project: @project)
    end
    Timecop.travel(1.minute.ago) do
      entry = TimeLogEntry.create!(user: @user, project: @project)
    end
    entry.close
    @project.worked_time(2.minutes.ago, Time.zone.now).should eql(60) 
  end
end

