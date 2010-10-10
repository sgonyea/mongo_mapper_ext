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
