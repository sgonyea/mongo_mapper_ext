# 
# ObjectID
# 
# Mongo::ObjectID.class_eval do  
#   def == other
#     self.to_s == other.to_s
#   end
# 
#   def to_yaml *args
#     to_s.to_yaml *args
#   end
# end

MongoMapper::Plugins::Associations::InArrayProxy.class_eval do
  def delete(doc)
    ids.delete(doc.id)
    klass.delete(doc.id)
    reset
  end
end

#
# Problem after destroying model the :to_param method returns :nill, 
# and we can't use :to_param in view (for example in ajax to remove element with id from the screen).
#
module MongoMapper
  module Plugins
    module Rails
      module InstanceMethods
        # def to_param
        #   id.to_s if persisted? # old realization
        # end
        def to_param
          id.to_s
        end
      end
    end
  end
end