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
module MongoMapper::Plugins::Rails
  module InstanceMethods
    # def to_param
    #   id.to_s if persisted? # old realization
    # end
    def to_param
      id.to_s
    end
  end
end


# 
# Use class alias instead of class name, because it causes foreign keys like 'models_account_id' instead of 'account_id' if
# for models like Models::Account
# 
module MongoMapper::Plugins::Associations
  class ManyDocumentsProxy
      def foreign_key
        # options[:foreign_key] || proxy_owner.class.name.to_s.underscore.gsub("/", "_") + "_id"
        options[:foreign_key] || proxy_owner.class.alias.to_s.underscore.gsub("/", "_") + "_id"
      end
  end
end