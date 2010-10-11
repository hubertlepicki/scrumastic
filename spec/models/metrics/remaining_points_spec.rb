require 'spec_helper'

describe Metrics::RemainingPoints do
  before :each do
    @user = User.create! valid_user_attributes
    @project = Project.create! valid_project_attributes
  end

  it "should be collected for given day for project" do
    Metrics::RemainingPoints.log
    Metrics::RemainingPoints.first.value.should eql(0.0)
  end

  it "should be collected for different projects individually" do
    @project2 = Project.create! valid_project_attributes("Test2")
    Metrics::RemainingPoints.log
    Metrics::RemainingPoints.count.should eql(2)
  end

  it "should be updated during the day if value changes" do
    @user_story = UserStory.create!( who: "registered user", what: "play",
                                     reason: "win cash", project: @project,
                                     story_points: 3 )
    Metrics::RemainingPoints.log
    Metrics::RemainingPoints.first.reload.value.should eql(3.0)

    @user_story = UserStory.create!( who: "registered user", what: "play",
                                     reason: "win cash", project: @project,
                                     story_points: 2 )
  
     
    Metrics::RemainingPoints.log
    Metrics::RemainingPoints.first.reload.value.should eql(5.0)
  end

  it "should not include closed user stories" do
    @user_story = UserStory.create!( who: "registered user", what: "play",
                                     reason: "win cash", project: @project,
                                     story_points: 3, state: "closed" )
    Metrics::RemainingPoints.log
    Metrics::RemainingPoints.first.value.should eql(0.0)
  end

  it "should save project reference" do
    Metrics::RemainingPoints.log
    Metrics::RemainingPoints.first.project.should eql(@project)
  end
end

