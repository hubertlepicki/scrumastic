require 'spec_helper'

describe Sprint do
  before(:each) do
    @admin = User.create!(valid_user_attributes)
    @project = Project.create!(valid_project_attributes)
  end
  
  it "should create first sprint for the project" do
    sprint = Sprint.create!(project: @project)
    sprint.should_not be_new_record
    sprint.project.id.should eql(@project.id)
    @project.sprints.should include(sprint)
  end

  it "should require project to be associated with" do
    Sprint.create.should be_new_record
  end

  it "should initiate first sprint name to 'Sprint 1'" do
    Sprint.create(project: @project).name.should eql("Sprint 1")
  end

  it "should initiate sprint's start and end dates" do
    sprint = Sprint.create(project: @project)
    sprint.start_date.should < sprint.end_date
  end

  it "should create second sprint for the project" do
    Sprint.create(project: @project)
    s = Sprint.create(project: @project)
    s.should_not be_new_record
  end

  it "should initiate second sprint start date to 1 day after last sprint, and end date in 2 weeks from then" do
    sprint1 = Sprint.create(project: @project)
    sprint2 = Sprint.create(project: @project)
    sprint2.start_date.should > sprint1.end_date
    sprint2.end_date.should > sprint2.start_date
    sprint2.start_date.should > sprint1.end_date
  end

  it "should set default sprint dates to mondays and fridays" do
    sprint1= Sprint.create(project: @project)
    sprint2 = Sprint.create(project: @project)
    sprint1.start_date.should be_monday
    sprint1.end_date.should be_friday
    sprint2.start_date.should be_monday
    sprint2.end_date.should be_friday
  end

  it "should prevent nested sprint dates" do
    Sprint.create(project: @project, start_date: Time.zone.now, end_date: 11.days.from_now)
    Sprint.create(project: @project, start_date: 2.days.from_now, end_date: 13.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: Time.zone.now, end_date: 5.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: Time.zone.now, end_date: 11.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: 2.days.from_now, end_date: 11.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: Time.zone.now, end_date: 13.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: 2.days.ago, end_date: 5.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: 2.days.ago, end_date: 20.days.from_now).should be_new_record
    Sprint.create(project: @project, start_date: 12.days.from_now, end_date: 22.days.from_now).should_not be_new_record
  end

  it "should prevent start_date >= end_date" do
    Sprint.create(project: @project, start_date: 1.day.from_now, end_date: 1.day.from_now).should be_new_record
    Sprint.create(project: @project, start_date: 1.day.from_now, end_date: 1.day.ago).should be_new_record
  end

  it "should have unique name" do
    Sprint.create(project: @project)
    Sprint.create(project: @project, name: "Sprint 1").should_not be_valid
  end

  it "should be possible to assing formatted date" do
    s = Sprint.create(project: @project, formatted_start_date: "21/02/2010", formatted_end_date: "28/02/2010")
    s.start_date.should eql(Time.parse("21/02/2010"))
    s.end_date.should eql(Time.parse("28/02/2010"))
    s.formatted_start_date.should eql("21/02/2010")
    s.formatted_end_date.should eql("28/02/2010")
  end
end
