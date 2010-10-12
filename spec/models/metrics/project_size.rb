require 'spec_helper'

describe Metrics::ProjectSize do
  before :each do
    @project = Project.create(valid_project_attributes.merge(
      :repository_url => "/tmp/example_repo",
      :application_regexp => "app.rb",
      :tests_regexp => "test.rb"))
    create_example_repo
  end

  it "should be calculated for given project when all information is available" do
    Metrics::ProjectSize.log
    @project.project_size_metrics.count.should eql(1)
    @project.project_size_metrics.first.value.should eql(2.0)
  end

  it "should not be calculated when repository could not be updated" do
    repo_mock = mock("Repo")
    repo_mock.should_receive(:update).and_return(false)
    @project.should_receive(:repository).and_return repo_mock
    Project.should_receive(:all).and_return([@project])
    Metrics::ProjectSize.log
    puts @project.project_size_metrics.to_a.inspect
    @project.project_size_metrics.count.should eql(0)
  end

  it "should not be calculated when application_regexp is blank" do
    @project.update_attributes :application_regexp => nil
    Metrics::ProjectSize.log
    @project.project_size_metrics.count.should eql(0)
  end

  it "should be updated during the day" do
    Metrics::ProjectSize.log
    system "cd /tmp/example_repo && echo 'puts 3' >> app.rb && git add . && git commit -m 'one more line'" 
    Metrics::ProjectSize.log
    @project.project_size_metrics.count.should eql(1)
    @project.project_size_metrics.first.value.should eql(3.0)
  end
end

