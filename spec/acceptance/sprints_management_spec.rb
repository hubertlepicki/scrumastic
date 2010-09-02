# encoding: UTF-8
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Sprints management", %q{
  In order to better manage their project
  As a signed in user
  I want to be able to divide project into sprints
} do
  
  scenario "Creating a new sprint" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])
    sign_in_as("Hubert")
    click_link "Project 1"
    sleep(1)
    click_link "Create new sprint"

    within(:css, "form.new_sprint") do
      click_button "Submit"
    end

    Sprint.count.should eql(1)
  end

  scenario "Deleting a sprint" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])
    sprint = Sprint.new(project: project, start_date: 2.days.ago)
    sprint.save

    sign_in_as("Hubert")
    click_link "Project 1"
    sleep(1)
    click_link "Delete Sprint 1"

    Sprint.count.should eql(0)
  end

  scenario "Editing a sprint" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])
    sprint = Sprint.new(project: project, start_date: 2.days.ago)
    sprint.save

    sign_in_as("Hubert")
    click_link "Project 1"
    sleep(1)
    click_link "Edit Sprint 1"
    fill_in "sprint_#{sprint.id}_goal", with: "To be best"

    within(:css, "form.edit_sprint") do
      click_button "Submit"
    end

    Sprint.first.goal.should eql("To be best")
  end


end
