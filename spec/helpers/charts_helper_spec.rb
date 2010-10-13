require 'spec_helper'

describe ChartsHelper do
  it "should return array of metric values within duration of project" do
    @project = Project.create valid_project_attributes
    @sprint = Sprint.create!(project: @project, start_date: 2.days.ago.midnight, end_date: 3.days.from_now.midnight)
    @sprint = Sprint.create!(project: @project, start_date: 5.days.from_now.midnight, end_date: 10.days.from_now.midnight)

    Metrics::ProjectSize.create!(project: @project, value: 3.0, date: 1.days.ago.midnight)
    Metrics::ProjectSize.create!(project: @project, value: 2.0, date: 2.days.from_now.midnight)

    data, labels = data_for_chart(@project, @project.project_size_metrics) 
    data.values.size.should eql(13)
    data.values[0].should be_nil
    data.values[1].should eql(3.0)
    data.values[4].should eql(2.0)
  end
end
