module MongoMapper::Plugins::BelongsToWithCounterCache
  extend ActiveSupport::Concern

  module ClassMethods                
    # 
    # CounterCache
    # belongs_to :item, counter_cashe: true
    # 
    def belongs_to association_id, options={}, &extension          
      # options.must_not.include :counter_cashe
      if options.delete(:counter_cache)
        association_id = association_id.to_s
        association_key = "#{association_id}_id"
        cache_attribute = "#{self.alias.pluralize.underscore}_count"
        cache_class = if class_name = options[:class_name]
          class_name.constantize
        else
          association_id.classify.constantize
        end
        raise "key :#{cache_attribute} not defined on :#{cache_class}!" unless cache_class.keys.include? cache_attribute            
        increase_method_name = "increase_#{cache_class.alias.underscore}_#{self.alias.pluralize.underscore}_counter"
        decrease_method_name = "decrease_#{cache_class.alias.underscore}_#{self.alias.pluralize.underscore}_counter"

        define_method increase_method_name do
          cache_class.upsert!({id: self.send(association_key)}, :$inc => {cache_attribute => 1})
        end
        protected increase_method_name            

        define_method decrease_method_name do
          cache_class.upsert!({id: self.send(association_key)}, :$inc => {cache_attribute => -1})
        end
        protected decrease_method_name

        after_create increase_method_name
        after_destroy decrease_method_name
      end
      super association_id, options, &extension
    end
  end
  
end