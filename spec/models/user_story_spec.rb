require 'spec_helper'

describe UserStory do
  before(:each) do
    @admin = User.create!(valid_user_attributes)
    @project = Project.create!(valid_project_attributes)
  end
  
  it "should create user stories without attaching them to backlog" do
    UserStory.create!( who: "registered user", what: "play",
                       reason: "win cash", project: @project)
  end

  it "should be to create a bug report" do
    bug = UserStory.create( who: "registered user", what: "play",
                            reason: "win cash", project: @project, bug: true)
    bug.bug.should be_true
  end

  it "should be possible to move story from incubator to backlog" do
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project )
    story.move_to_backlog!
    story.in_backlog.should be_true
  end

  it "should be possible to move story back to incubator" do
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              in_backlog: true )
    story.move_to_incubator!
    story.in_backlog.should be_false
  end

  it "should be possible to move story to given sprint" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project )
    story.move_to_sprint!(sprint)
    story.sprint.id.should eql(sprint.id)
    sprint.user_stories.should include(story)
  end

  it "should be possible to remove story from sprint" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              sprint_id: sprint.id, in_backlog: true )
    story.move_to_incubator!
    story.sprint.should be_nil
    story.in_backlog.should be_false

    story.move_to_sprint!(sprint)
    story.move_to_backlog!
    story.sprint.should be_nil
    story.in_backlog.should be_true
  end

  it "should not delete Sprint with assigned user stories" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              sprint_id: sprint.id, in_backlog: true )
    sprint.destroy.should be_false
    Sprint.count.should eql(1)
  end

  it "should be deleted when project is deleted" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              sprint_id: sprint.id, in_backlog: true )
    story2 = UserStory.create( who: "registered user", what: "play",
                               reason: "win cash", project: @project )
    @project.destroy

    UserStory.count.should eql(0)
  end

  it "should be open by default" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              sprint_id: sprint.id, in_backlog: true )
    story.state.should eql("open")
  end

  it "should be possible to assign user story to user" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              sprint_id: sprint.id, in_backlog: true,
                              user: @admin )
    story.user.id.should eql(@admin.id)
  end

  it "should be possible to assign story points to a story" do
    sprint = Sprint.create!(project: @project)
    story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project,
                              sprint_id: sprint.id, in_backlog: true,
                              user: @admin )
    story.story_points.should eql(0) # default
    story.story_points = 20
    story.save
    story.reload.story_points.should eql(20)
  end
end

