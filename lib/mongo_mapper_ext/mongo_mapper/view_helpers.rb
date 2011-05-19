# 
# HTML helpers
# 
[MongoMapper::EmbeddedDocument, MongoMapper::Document].each do |aclass|
  aclass.class_eval do
    def dom_id
      new_record? ? "new_#{self.class.name.underscore}" : to_param
    end
  end
end