module MongoMapper  
  # 
  # Connection Pool
  # 
  class ConnectionsPool < Hash    
    def [](database_alias)
      database_alias = database_alias.to_s
      unless connection = super(database_alias)            
        raise "unknown database alias :#{database_alias}" unless MongoMapper.db_config.include? database_alias
        db_options = MongoMapper.db_config[database_alias]        
        connection = Mongo::Connection.new(db_options['host'], db_options['port'], logger: MongoMapper.logger)
  
        # if defined?(PhusionPassenger)
        #   PhusionPassenger.on_event(:starting_worker_process) do |forked|
        #     connection.connect_to_master if forked
        #   end
        # end
    
        self[database_alias] = connection
      end            
      return connection
    end
  end
  
  
  # 
  # Databases Pool
  # 
  class DatabasesPool < Hash
    def [](database_alias)
      database_alias = database_alias.to_s
      unless db = super(database_alias)
        raise "unknown database alias :#{database_alias}" unless MongoMapper.db_config.include? database_alias
        db_options = MongoMapper.db_config[database_alias]
        name = db_options['name']
        raise "database name should be a string (#{name})!" unless name.is_a?(String)
        db = MongoMapper.connections[database_alias].db name
        self[database_alias] = db
      end
      return db
    end
  end
  
  class << self
    attr_accessor :db_config

    def db_config      
      @db_config ||= {}
    end

    def connections
      @connections ||= ConnectionsPool.new
    end

    def databases
      @databases ||= DatabasesPool.new
    end
    
    def use_database database_alias
      database_alias = database_alias.to_s
      raise "unknown database alias :#{database_alias}" unless MongoMapper.db_config.include? database_alias
      MongoMapper.connection = MongoMapper.connections[database_alias]
      MongoMapper.database = MongoMapper.db_config[database_alias]['name']
    end
  end                              
end


# 
# Plugin
# 
module MongoMapper::Plugins::DbConfig
  extend ActiveSupport::Concern
  
  module ClassMethods                
    # 
    # Connect to database_alias specified in config
    # 
    def use_database database_alias
      database_alias = database_alias.to_s
      raise "unknown database alias :#{database_alias}" unless MongoMapper.db_config.include? database_alias
  
      self.connection MongoMapper.connections[database_alias]
      set_database_name MongoMapper.db_config[database_alias]['name']
    end                
  end
  
end