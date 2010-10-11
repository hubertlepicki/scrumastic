require 'spec_helper'

describe Metrics::Velocity do
  before :each do
    @user = User.create! valid_user_attributes
    @project = Project.create! valid_project_attributes
    @sprint = Sprint.create! project: @project, name: "Test...", start_date: 2.days.ago.utc, end_date: 2.days.from_now.utc
  end

  it "should be calculated for given project and sprint when sprint log entries are calculated" do
    UserStory.create! sprint: @sprint, project: @project, what: "what", who: "who", story_points: 16, state: "open"
    UserStory.create! sprint: @sprint, project: @project, what: "what", who: "who", story_points: 8, state: "closed"
    @sprint.log
    Metrics::Velocity.first.value.should eql(8.0)
  end
 
  it "should should be updated when sprint log entries are updated" do
   story1 = UserStory.create! sprint: @sprint, project: @project, what: "what", who: "who", story_points: 16, state: "open"
    story2 = UserStory.create! sprint: @sprint, project: @project, what: "what", who: "who", story_points: 8, state: "closed"
    @sprint.log
    story1.update_attributes state: "closed"
    @sprint.log
    Metrics::Velocity.first.value.should eql(24.0)
  end

end
