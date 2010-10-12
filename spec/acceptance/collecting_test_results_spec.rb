# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'acceptance_helper')

feature "Collecting test results", %q{
  In order to generate metrics ref tests
  As a CI system
  I want to update test results
} do
  
  scenario "Collecting results for project" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])

    visit "/projects/#{project.id}/collect_test_results?api_key=#{project.api_key}&passed=1&failed=2"
    Metrics::PassedTests.first.value.should eql(1.0)
    Metrics::FailedTests.first.value.should eql(2.0)
  end

  scenario "Updating results for project" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])

    visit "/projects/#{project.id}/collect_test_results?api_key=#{project.api_key}&passed=1&failed=2"
    visit "/projects/#{project.id}/collect_test_results?api_key=#{project.api_key}&passed=0&failed=5"
    Metrics::PassedTests.first.value.should eql(0.0)
    Metrics::FailedTests.first.value.should eql(5.0)
  end

  scenario "Authorizing test results update" do
    users = create_standard_users
    project = Project.create valid_project_attributes("Project 1", "test", users[:hubert])

    visit "/projects/#{project.id}/collect_test_results?api_key=invalidapikey&passed=1&failed=2"
    Metrics::PassedTests.count.should eql(0)
    Metrics::FailedTests.count.should eql(0)
  end
end 
