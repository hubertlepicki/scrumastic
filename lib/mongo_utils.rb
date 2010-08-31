module MongoUtils
  def self.from_string(string_or_array)
    if string_or_array.is_a?(Array)
     string_or_array.collect {|string| object_id_from_string(string)} 
    else
      object_id_from_string(string)
    end
  end

  def self.object_id_from_string(string)
    BSON::ObjectID.from_string(string)
  end
end
