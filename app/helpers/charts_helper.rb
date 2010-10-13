module ChartsHelper
  def data_for_chart(project, metrics)
    return [{}, []] if project.start_date.nil?

    dates_values = Hash[*(project.start_date..project.end_date).collect { |k| [k, nil] }.flatten]
    metrics.each do |metric|
      dates_values[metric.date.to_date] = metric.value if dates_values.has_key? metric.date.to_date
    end 
    [dates_values, dates_values.keys.collect {|k| project.sprint_start_end_dates.include?(k) ? k.to_s(:short) : ""}.join("|")]
  end
end
