require 'mongo_mapper_ext'

# 
# Disabling indexes in testing environment
# 
if Object.const_defined?(:Rad)
  MongoMapper::Plugins::Indexes::ClassMethods.class_eval do        
    alias_method :original_ensure_index, :ensure_index
    def ensure_index_stub *args; end
  end
  
  rad.after :mode, bang: false do
    if rad.production?
      MongoMapper::Plugins::Indexes::ClassMethods.send :alias_method, :ensure_index, :original_ensure_index
    else
      MongoMapper::Plugins::Indexes::ClassMethods.send :alias_method, :ensure_index, :ensure_index_stub
    end
  end  
end


# 
# Clear db before each test
# 
rspec do
  def self.with_mongo_mapper
    before do
      MongoMapper.db_config.each do |db_alias, opt|      
        db = MongoMapper.databases[db_alias]
        db.collection_names.each do |name|
          next if name =~ /^system\./
          db.collection(name).drop
        end
      end
    end
  end
end


# 
# Silence logger
# 
MongoMapper.logger = Logger.new(nil)
if defined? Paperclip
  Paperclip.class_eval do
    def self.logger
      @logger ||= Logger.new(nil)
    end
  end
end


# 
# Database
# 
rspec do
  def self.with_test_database
    before :all do      
      MongoMapper.db_config = {
        # 'global' => {'name' => 'global_test'},
        'default' => {'name' => "default_test"}
      }
      
      MongoMapper.database = 'default_test'      
    end
  end
end