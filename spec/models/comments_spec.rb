# encoding: UTF-8
require 'spec_helper'

describe "Comment" do
  before(:each) do
    @project = Project.create(valid_project_attributes)
    @hubert = User.create(valid_user_attributes "Hubert")
    @deborah = User.create(valid_user_attributes "Deborah")
    @story = UserStory.create( who: "registered user", what: "play",
                              reason: "win cash", project: @project )
  end

  it "should be possible to comment on projects" do
    Comment.create(user_story: @story, user: @user, content: "This is cool.")
  end

  it "should be possible to attach file" do
    c = Comment.create(user_story: @story, user: @user, content: "This is cool.",
                       attachment: File.new("spec/fixtures/logo.png"))
    c.attachment.should be_present
  end
end
