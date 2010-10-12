require 'spec_helper'

describe Metrics::CodeComplexity do
  before :each do
    @project = Project.create(valid_project_attributes.merge(
      :repository_url => "/tmp/example_repo",
      :application_regexp => "app.rb",
      :tests_regexp => "test.rb"))
    create_example_repo
  end

  it "should be calculated for given project when all information is available" do
    Metrics::CodeComplexity.log
    @project.code_complexity_metrics.count.should eql(1)
  end

  it "should not be calculated when repository could not be updated" do
    repo_mock = mock("Repo")
    repo_mock.should_receive(:update).and_return(false)
    @project.should_receive(:repository).and_return repo_mock
    Project.should_receive(:all).and_return([@project])
    Metrics::CodeComplexity.log
    @project.code_complexity_metrics.count.should eql(0)
  end

  it "should not be calculated when application_regexp is blank" do
    @project.update_attributes :application_regexp => nil
    Metrics::CodeComplexity.log
    @project.code_complexity_metrics.count.should eql(0)
  end

  it "should be updated during the day" do
    Metrics::CodeComplexity.log
    system "cd /tmp/example_repo && echo 'puts def a; if (true == false) return 1; else return 2; end' >> app.rb && git add . && git commit -m 'one more line'" 
    Metrics::CodeComplexity.log
    @project.code_complexity_metrics.count.should eql(1)
    @project.code_complexity_metrics.first.value.should > 0.0
  end

  it "should be one pending"
end
