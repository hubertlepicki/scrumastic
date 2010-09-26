# encoding: UTF-8

require 'spec_helper'

describe "Project" do
  before(:each) do
    @admin = User.create!(valid_user_attributes)
  end

  it "should be saved in the database" do
    p = Project.create!(valid_project_attributes)
    p.should_not be_new_record
    p.name.should eql("Test project")
    p.description.should eql("Some description")
  end

  it "should have unique name" do
    Project.create!(valid_project_attributes)
    p2 = Project.create(valid_project_attributes)
    p2.should be_new_record
    p2.errors[:name].should_not be_nil
  end

  it "should have project owner" do
    p = Project.create!(valid_project_attributes)
    p.owner.should eql(@admin)
  end
  
  it "should be possible to upload a logo to a project" do
    p = Project.create!(valid_project_attributes.merge(
          {:logo => File.new("#{::Rails.root}/spec/fixtures/logo.png")}
        ))
    p.logo.should be_present
  end

  it "should be possible to specify git repository url"
  it "should be possible to specify hudson url"

  it "should be possible to remove a logo from a project by setting a boolean field" do
    p = Project.create!(valid_project_attributes.merge(
          {:logo => File.new("#{::Rails.root}/spec/fixtures/logo.png")}
        ))
    p.remove_logo = true
    p.save
    p.logo.thumb.url.should eql("/images/fallback/logo/thumb_default.png")
  end
end

describe Project, "user roles" do
  before(:each) do
    @project = Project.create(valid_project_attributes)
    @hubert = User.create(valid_user_attributes "Hubert")
    @deborah = User.create(valid_user_attributes "Deborah")
    @lukasz = User.create(valid_user_attributes "Lukasz")
    @wojtek = User.create(valid_user_attributes "Wojtek")
    @alex = User.create(valid_user_attributes "Alex")
    @david = User.create(valid_user_attributes "David")
  end

  it "should be possible to assign scrum master role" do
    @project.scrum_master = @hubert
    @project.save
    @project.scrum_master.id.should eql(@hubert.id)
    @hubert.role_in_project(@project).should eql(:scrum_master)
  end

  it "should be possible to assign product owner role" do
    @project.product_owner = @deborah
    @project.save
    @project.product_owner.id.should eql(@deborah.id)
    @deborah.role_in_project(@project).should eql(:product_owner)
  end

  it "should be possible to assign team member role" do
    @project.team_member_ids = [@lukasz.id.to_s, @wojtek.id.to_s]
    @project.save
    @project.team_members.should include(@lukasz)
    @project.team_members.should include(@wojtek)
    @lukasz.role_in_project(@project).should eql(:team_member)
    @wojtek.role_in_project(@project).should eql(:team_member)
  end

  it "should be possible to assign stakeholder role" do
    @project.stakeholder_ids = [@david.id.to_s, @alex.id.to_s]
    @project.save
    @project.stakeholders.should include(@david)
    @project.stakeholders.should include(@alex)
    @david.role_in_project(@project).should eql(:stakeholder)
    @alex.role_in_project(@project).should eql(:stakeholder)
  end

  it "should not be possible to assign two roles for one user" do
    @project.product_owner = @hubert
    @project.scrum_master = @hubert
    @project.save.should be_false
    @project = @project.reload

    @project.product_owner = @hubert
    @project.team_member_ids = [@hubert.id.to_s]
    @project.save.should be_false
    @project = @project.reload

    @project.product_owner = @hubert
    @project.stakeholder_ids = [@hubert.id.to_s]
    @project.save.should be_false
    @project = @project.reload

    @project.product_owner = @hubert
    @project.team_member_ids = [@hubert.id.to_s]
    @project.save.should be_false
    @project = @project.reload

    @project.product_owner = @hubert
    @project.stakeholder_ids = [@hubert.id.to_s]
    @project.save.should be_false
    @project = @project.reload

    @project.team_member_ids = [@hubert.id.to_s]
    @project.stakeholder_ids = [@hubert.id.to_s]
    @project.save.should be_false
    @project = @project.reload
  end

  it "should assign users unique roles" do
    @project.scrum_master = @hubert
    @project.product_owner = @deborah
    @project.team_member_ids = [@wojtek.id.to_s, @lukasz.id.to_s]
    @project.stakeholder_ids = [@alex.id.to_s, @david.id.to_s]
    @project.save.should be_true
  end

  it "should clear user's role in project when removing user from database" do
    @project.scrum_master = @hubert
    @project.product_owner = @deborah
    @project.team_member_ids = [@wojtek.id.to_s, @lukasz.id.to_s]
    @project.stakeholder_ids = [@alex.id.to_s, @david.id.to_s]
    @project.save

    @hubert.destroy
    @project.reload.scrum_master_id.should be_nil

    @deborah.destroy
    @project.reload.product_owner_id.should be_nil

    @wojtek.destroy
    @project.reload.team_member_ids.count.should eql(1)

    @lukasz.destroy
    @project.reload.team_member_ids.count.should eql(0)

    @alex.destroy
    @project.reload.stakeholder_ids.count.should eql(1)

    @david.destroy
    @project.reload.stakeholder_ids.count.should eql(0)
  end

end

describe Project, "reports" do
  before(:each) do
    @admin = User.create!(valid_user_attributes)
    @project = Project.create!( valid_project_attributes.merge(
                                  {repository_url: "http://github.com/hubertlepicki/scrumastic.git"}
                              ))

    @sprint = Sprint.create!( :project => @project, 
                              :start_date => Time.parse("2010-08-15 00:00:00"),
                              :end_date => Time.parse("2010-09-15 00:00:00") )

    SCM::GitAdapter.stub!(:clone_repository).and_return SCM::GitAdapter.new("#{Rails.root}")
    @project.prepare_reporting
  end

  it "should save into database project size during the days within Sprints" do
    @project.size_at["2010-08-29"].should eql(11929) 
    @project.size_at["2010-09-13"].should eql(17418) 
    @project.size_at["2010-09-15"].should eql(17502) 
  end

  it "should not save size entries when can't get this information from repository" do
    @project.size_at["2010-08-16"].should be_nil
  end

  it "should save into database test to code ratio" do
    @project.test_to_code_ratio_at["2010-08-29"].should eql(4.6289) 
    @project.test_to_code_ratio_at["2010-09-13"].should eql(1.0877) 
    @project.test_to_code_ratio_at["2010-09-15"].should eql(1.0655) 
  end

  it "should save into database average ABC result" do
    @project.complexity_at["2010-08-29"].should eql(4.6289) 
    @project.complexity_at["2010-09-13"].should eql(1.0877) 
    @project.complexity_at["2010-09-15"].should eql(1.0655) 
  end
end

