module MongoMapper::Plugins::AttributeConvertors
  extend ActiveSupport::Concern
  
  module ClassMethods
    ATTRIBUTE_CONVERTORS = {
      line: {
        from_string: -> s {(s || "").split(',').collect{|s| s.strip}},
        to_string:   -> v {v.join(', ')}
      },
      column: {
        from_string: -> s {(s || "").split("\n").collect{|s| s.strip}},
        to_string:   -> v {v.join("\n")}
      },
      yaml: {
        from_string: -> s {YAML.load s rescue {}},
        to_string:   -> v {              
          # MongoMapper uses it's internal Hash that doesn't support to_yaml
          hash = {}; v.each{|k, v| hash[k] = v}               
          hash.to_yaml.strip
        }
      },
      json: {
        from_string: -> s {JSON.parse s rescue {}},
        to_string:   -> v {
          # MongoMapper uses it's internal Hash that doesn't support to_yaml
          hash = {}; v.each{|k, v| hash[k] = v}               
          hash.to_json.strip
        }
      }
    }
    
    
    # 
    # supporf for :as_string option
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
      converter = ATTRIBUTE_CONVERTORS[converter_name]
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
    
  end
  
end