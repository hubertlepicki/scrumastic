# encoding: UTF-8
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Time logging", %q{
  In order to trace spent time
  As a team member & scrum master
  I want to log my time
} do
  
  scenario "Logging time for User Story" do
    users = create_standard_users
    project = Project.create! valid_project_attributes("Project 1", "test", users[:hubert])
    sprint = Sprint.create! :project => project, :start_date => 2.days.ago
    user_story = UserStory.create! :project => project, :who => "foo", :what => "bar"
    user_story.move_to_sprint!(sprint)
    sign_in_as "Hubert"
    click_link "Project 1"
  
    click_link "Start work"
    TimeLogEntry.count.should eql(1)
    TimeLogEntry.first.should be_current
    click_link "Stop work"
    TimeLogEntry.first.should_not be_current
  end
end
