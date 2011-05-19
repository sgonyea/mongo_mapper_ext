# 
# Custom Logger
# 
MongoMapper.class_eval do
  class << self
    
    def logger
      unless @logger
        @logger = if "irb" == $0
          Logger.new(STDOUT)
        else          
          if defined?(Rails)
            Rails.test? ? Logger.new(nil) : Rails.logger
          else
            Logger.new(STDOUT)
          end
        end
      end
      @logger
    end
    
    def logger= logger
      @logger = logger
    end
    
  end
end


# 
# silence logging
# 
Mongo::Connection.class_eval do
  attr_writer :logger
end

MongoMapper.class_eval do
  def self.temporary_silince_logger &block
    logger, nil_logger = self.logger, Logger.new(nil)
    
    begin  
      MongoMapper.logger = nil_logger
      connections.each do |name, connection|
        connection.logger = nil_logger
      end
      block.call
    ensure
      MongoMapper.logger = logger
      connections.each do |name, connection|
        connection.logger = logger
      end
    end
  end
  
  def self.use_database database_alias
    database_alias = database_alias.to_s
    raise "unknown database alias :#{database_alias}" unless MongoMapper.db_config.include? database_alias
    MongoMapper.connection = MongoMapper.connections['default']
    MongoMapper.database = MongoMapper.db_config['default']['name']
  end
end


# 
# Silence index creation
# 
MongoMapper::Plugins::Indexes::ClassMethods.class_eval do
  def ensure_index_with_silent_logger *args
    MongoMapper.temporary_silince_logger do
      ensure_index_without_silent_logger *args
    end
  end
  
  alias_method_chain :ensure_index, :silent_logger
end