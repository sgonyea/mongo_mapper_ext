module MongoMapper
  # def self.deferred; @deferred ||= [] end
  # def self.call_deferred
  #   deferred.every.call
  #   deferred.clear
  # end
  
  module Plugins
    module Micelaneous
      
      module InstanceMethods
        def upsert *args
          self.class.upsert id, *args
        end
      end
      
      module ClassMethods
        STRING_CONVERTORS = {
          line: {
            from_string: -> s {(s || "").split(',').collect{|s| s.strip}},
            to_string:   -> v {v.join(', ')}
          },
          yaml: {
            from_string: -> s {
              {YAML.load s}rescue{{}}
            },
            to_string:   -> v {              
              # MongoMapper uses it's internal Hash that doesn't support to_yaml
              hash = {}; v.each{|k, v| hash[k] = v}               
              hash.to_yaml.strip
            }
          },
          json: {
            from_string: -> s {JSON.parse s},
            to_string:   -> v {          
              # MongoMapper uses it's internal Hash that doesn't support to_yaml
              hash = {}; v.each{|k, v| hash[k] = v}               
              hash.to_json.strip
            }
          }
        }
        
        # 
        # custom key accessors
        # 
        def key(*args)
          key = super                    
          if converter_name = key.options[:as_string]
            key_name = key.name.to_sym            
            available_as_string key_name, converter_name
            attr_protected "#{key_name}_as_string".to_sym if key.options[:protected]            
          end
          key
        end
        
        def available_as_string key_name, converter_name
          converter = STRING_CONVERTORS[converter_name]
          raise "unknown converter name :#{converter_name} for :#{key_name} key!" unless converter
          
          from_string, to_string = converter[:from_string], converter[:to_string]
          key_name_as_string = "#{key_name}_as_string".to_sym
          define_method key_name_as_string do
            cache[key_name_as_string] ||= to_string.call(self.send(key_name))
          end
          define_method "#{key_name_as_string}=" do |value|
            cache.delete key_name_as_string                        
            self.send "#{key_name}=", from_string.call(value)
          end
        end
        
        def available_as_yaml key_name
          raise "delimiter not specified for :#{key_name} key!" unless delimiter
          method = "#{key_name}_as_string"
          define_method method do
            self.send(key_name).join(delimiter)
          end
          define_method "#{method}=" do |value|            
            value = (value || "").split(delimiter.strip).collect{|s| s.strip}
            self.send "#{key_name}=", value
          end
        end
        
        
        # 
        # model_name
        # 
        def model_name *args  
          @model_name = args.first unless args.empty?
          @model_name ||= name          
        end
        
        
        # 
        # Sequentiall :all for big collection
        # 
        def all_sequentially &block
          page, per_page = 1, 5
          begin
            results = paginate(page: page, per_page: per_page, order: '_id asc')
            results.each{|o| block.call o}
            page += 1
          end until results.blank? or results.size < per_page
        end
        
        
        # 
        # Deferred execution
        # 
        # def defer &block
        #   MongoMapper.deferred << block
        # end
        
        
        # 
        # Connect to database_alias specified in config
        # 
        def use_database database_alias
          # defer do
          database_alias = database_alias.to_s
          MongoMapper.db_config.must.include database_alias
      
          self.connection MongoMapper.connections[database_alias]
          set_database_name MongoMapper.db_config[database_alias]['name']
          # end
        end                
        
        
        # 
        # shortcut for upsert
        # 
        def upsert *args
          collection.upsert *args          
        end
        
        
        # 
        # CounterCache
        # belongs_to :item, counter_cashe: true
        # 
        def belongs_to association_id, options={}, &extension          
          options.must_not.include :counter_cashe
          if options.delete(:counter_cache) || options.delete('counter_cache')
            association_id = association_id.to_s
            association_key = "#{association_id}_id"
            cache_attribute = "#{name.pluralize.underscore}_count"
            cache_class = association_id.classify.constantize
            cache_class.keys.must.include cache_attribute            
            increase_method_name = "increase_#{cache_class.name.underscore}_#{name.pluralize.underscore}_counter"
            decrease_method_name = "decrease_#{cache_class.name.underscore}_#{name.pluralize.underscore}_counter"
            
            define_method increase_method_name do
              cache_class.upsert self.send(association_key), :$inc => {cache_attribute => 1}
            end
            protected increase_method_name            
            
            define_method decrease_method_name do
              cache_class.upsert self.send(association_key), :$inc => {cache_attribute => -1}
            end
            protected decrease_method_name
            
            after_create increase_method_name
            after_destroy decrease_method_name
          end
          
          super association_id, options, &extension
        end
        
      end
      
    end
  end
end