# encoding: UTF-8
require File.join(File.dirname(__FILE__), '/acceptance_helper')

feature "Publishing shouts", %q{
  In order to inform other people what's going on
  As a signed in user
  I want to be able to publish shouts 
} do
  
  scenario "Publishing shouts" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])
    sign_in_as("Hubert")
    click_link "Project 1"

    fill_in "What's going on?", :with => "Bitchin'!"
    project.shouts.count.should eql(1)
  end
end
