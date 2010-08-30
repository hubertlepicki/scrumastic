# encoding: UTF-8
require File.dirname(__FILE__) + '/acceptance_helper'

def fill_in_project_form(users)
    fill_in "Project name", with: "My first project"
    fill_in "Project description", with: "Hello world project!"

    drag "//*[@userid='#{users[:deborah].id}']", "//*[@id='product_owner_droppable']"
    drag "//*[@userid='#{users[:hubert].id}']", "//*[@id='scrum_master_droppable']"
    drag "//*[@userid='#{users[:wojtek].id}']", "//*[@id='team_members_droppable']"
    drag "//*[@userid='#{users[:lukasz].id}']", "//*[@id='team_members_droppable']"
    drag "//*[@userid='#{users[:alex].id}']", "//*[@id='stakeholders_droppable']"
    attach_file "Project logo", "#{::Rails.root}/spec/fixtures/logo.png"
    click_button "Submit"
end

def validate_project_details(project, users)
    project.product_owner.id.should eql(users[:deborah].id)
    project.scrum_master.id.should eql(users[:hubert].id)
    project.stakeholder_ids.should include(users[:alex].id.to_s)
    project.team_member_ids.should include(users[:lukasz].id.to_s)
    project.team_member_ids.should include(users[:wojtek].id.to_s)
    project.name.should eql("My first project")
    project.description.should eql("Hello world project!")
    project.logo.should be_present
end

feature "Project management", %q{
  In order to better manage their project
  As a signed in user
  I want to be able to manage projects
} do
  
  scenario "Creating project" do
    users = create_standard_users

    sign_in_as("Hubert")
    
    click_link "New project"
    fill_in_project_form users

    Project.count.should eql(1)
    project = Project.first
    validate_project_details(project, users)
  end

  scenario "Editing project" do
    users = create_standard_users
    project = Project.create!(valid_project_attributes("Test project", "Cool", users[:hubert]))
    sign_in_as("Hubert")

    click_link "Edit project"
    fill_in_project_form users

    validate_project_details(project.reload, users)
  end

  scenario "Removing project" do
    hubert = create_users("Hubert")[:hubert]
    project = Project.create!(valid_project_attributes("Test project", "Cool", hubert))
    sign_in_as("Hubert")

    click_link "Edit project"
    click_button "Delete this project"
    Project.count.should eql(0)
  end
end
