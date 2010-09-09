# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'acceptance_helper')

feature "User Stories management", %q{
  In order to express what needs to be done
  As a signed in user
  I want to be able to manage User Stories
} do
  
  scenario "Creating a new User Story" do
    users = create_standard_users
    project = Project.create! valid_project_attributes("Project 1", "test", users[:hubert])
    sprint = Sprint.create! :project => project
    sign_in_as "Hubert"
    click_link "Project 1"
    sleep 1
    click_link "New user story"
    fill_in "As a", :with => "someone"
    fill_in "I want to", :with => "do something"
    fill_in "so that", :with => "something happens"
    within(:css, "form.new_user_story") do
      click_button "Submit"
    end
    UserStory.count.should eql(1)
  end

  scenario "Moving User Story to backlog" do
    users = create_standard_users
    project = Project.create! valid_project_attributes("Project 1", "test", users[:hubert])
    sprint = Sprint.create! :project => project, :start_date => 2.days.ago
    user_story = UserStory.create! :project => project, :who => "foo", :what => "bar"

    sign_in_as "Hubert"
    click_link "Project 1"
    drag "//*[@data-id='#{user_story.id}']", "//*[@id='backlog_stories']"
    sleep 1
    UserStory.first.in_backlog.should eql(true)
  end
end
