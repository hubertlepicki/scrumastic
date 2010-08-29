# Include this module in Mongoid models and call array_attributes
# to use convinient setter for attributes with Array values.
# For example, when assigning nil or empty string as attribute
# it will be converted to empty array (useful for forms).
#
#     class MyModel
#       include Mongoid::Document
#       include ArrayAttributes
#       array_attributes_for :tags
#     end
#
#     (m = MyModel.first).tags = ""
#     m.tags
#     ==> []
module ArrayAttributes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def array_attributes(*attribute_names)
      attribute_names.each do |attr|
        self.class_eval do
          field attr, :type => Array, :default => []
          define_method "#{attr}=" do |passed_array|
            if passed_array.kind_of?(Array)
              write_attribute(attr, passed_array)
            else
              write_attribute(attr, [])
            end
          end
        end
      end
    end
  end
end