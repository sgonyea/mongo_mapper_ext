# 
# Disabling indexes in test environment
# 
# if Object.const_defined?(:RAILS_ENV) and Object.const_get(:RAILS_ENV) != 'production'
#   MongoMapper::Plugins::Indexes::ClassMethods.class_eval do
#     def ensure_index(name_or_array, options={})
#     end
#   end
# end

if Object.const_defined?(:Crystal) and Crystal.respond_to?(:run)
  MongoMapper::Plugins::Indexes::ClassMethods.class_eval do        
    alias_method :original_ensure_index, :ensure_index
    def ensure_index_stub *args; end
  end
  
  crystal.after :config do |config|
    if config.production?
      MongoMapper::Plugins::Indexes::ClassMethods.send :alias_method, :ensure_index, :original_ensure_index
    else
      MongoMapper::Plugins::Indexes::ClassMethods.send :alias_method, :ensure_index, :ensure_index_stub
    end
  end  
end


# 
# Clear db before each test
# 
RSpec::Core::ExampleGroup.class_eval do
  class << self
    def with_mongo_mapper
      before :each do
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
end
# Spec::Runner.configure do |config|
#   config.before(:each) do        
#   end
# end


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