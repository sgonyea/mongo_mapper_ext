module MongoMapper
  class ConnectionsPool < Hash
    def [](database_alias)
      database_alias = database_alias.to_s
      unless connection = super(database_alias)            
        MongoMapper.db_config.must.include database_alias
        db_options = MongoMapper.db_config[database_alias]        
        connection = Mongo::Connection.new(db_options['host'], db_options['port'], :logger => MongoMapper.logger)
      
        if defined?(PhusionPassenger)
          PhusionPassenger.on_event(:starting_worker_process) do |forked|
            connection.connect_to_master if forked
          end
        end
        
        self[database_alias] = connection
      end            
      return connection
    end
  end
  
  class DatabasesPool < Hash
    def [](database_alias)
      database_alias = database_alias.to_s
      unless db = super(database_alias)
        MongoMapper.db_config.must.include database_alias
        db_options = MongoMapper.db_config[database_alias]
        db = MongoMapper.connections[database_alias].db db_options['name'].must_be.a(String)
        self[database_alias] = db
      end
      return db
    end
  end
  
  class << self
    attr_accessor :db_config
    
    def db_config      
      # unless @db_config
      #   
      #   if defined?(::Rails) and defined?(DATABASE)              
      #     @db_config = {}
      #     DATABASE["#{::Rails.env}!"].to_h.each do |db_alias, options|
      #       @db_config[db_alias.to_s] = {
      #         'name' => options.name!,
      #         'host' => options.host(nil),
      #         'port' => options.port(nil)
      #       }
      #     end
      #   else
      #     @db_config = {}
      #     # raise "If you don't using Rails you must override this method and provide your own config!"
      #   end          
      # end
      @db_config ||= {}
    end
    
    def connections
      @connections ||= ConnectionsPool.new
    end
    
    def databases
      @databases ||= DatabasesPool.new
    end
  end
              
end