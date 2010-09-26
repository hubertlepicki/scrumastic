# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'acceptance_helper')

feature "Project reporting", %q{
  In order to get idea what is going on in project
  As a signed in user
  I want to be able to see project reporting
} do
  
  scenario "Seeing project size" do
    users = create_standard_users
    project = Project.create! valid_project_attributes("Project 1", "test", users[:hubert])
    project.update_attributes repository_url: "http://github.com/hubertlepicki/scrumastic.git"
    sprint = Sprint.create!( :project => project, 
                             :start_date => Time.parse("2010-08-29 00:00:00"),
                             :end_date => Time.parse("2010-09-15 00:00:00") )

    sign_in_as "Hubert"
    click_link "Project 1"
    sleep 1
    project.prepare_reporting
    click_link "Reports"
    page.find('//td[@id="size_2010-08-29"]').text.should eql("11929")
  end

end
