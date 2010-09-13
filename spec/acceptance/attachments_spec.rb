# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'acceptance_helper')

feature "Attachments management", %q{
  In order to share data with other users
  As a involved person
  I want to be able to manage files
} do
  
  scenario "Uploading a new attachment" do
    users = create_standard_users
    project = Project.create! valid_project_attributes("Project 1", "test", users[:hubert])
    sprint = Sprint.create! :project => project
    sign_in_as "Hubert"
    click_link "Project 1"
    sleep 1
    click_link "Files"
    click_link "Upload file"
    fill_in "Description", :with => "some random file"
    attach_file "File", "#{::Rails.root}/spec/fixtures/logo.png"
    within(:css, "form.new_attachment") do
      click_button "Submit"
    end
    project.attachments.count.should eql(1)
  end
end
