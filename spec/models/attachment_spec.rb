# encoding: UTF-8
require 'spec_helper'

describe "Attachment" do
  before(:each) do
    @hubert = User.create(valid_user_attributes "Hubert")
    @deborah = User.create(valid_user_attributes "Deborah")
    @project = Project.create(valid_project_attributes)
    @project.product_owner = @deborah
    @project.scrum_master = @hubert
    @alex = User.create(valid_user_attributes "Alex")
  end
 
  it "should be possible to upload a file" do
    Attachment.create! file: File.new("#{Rails.root}/spec/fixtures/logo.png"), project: @project
  end

  it "should be accessible only to people involved in project" do
    attachment = Attachment.create! file: File.new("#{Rails.root}/spec/fixtures/logo.png"), project: @project
    Can.edit?(@hubert, attachment).should be_true
    Can.edit?(@deborah, attachment).should be_true
    Can.edit?(@alex, attachment).should be_false
  end
end
