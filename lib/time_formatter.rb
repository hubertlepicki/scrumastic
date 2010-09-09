module TimeFormatter
  def self.format(time_in_seconds)
    "#{time_in_seconds/3600}h #{(time_in_seconds / 60) % 60}m #{time_in_seconds % 60}s"
  end
end
