# Measures MongoDB requests time and adds it to log

if defined?(Rails) and RAILS_ENV == 'development'
  Mongo::Connection.class_eval do  
    def send_message_with_time operation, message, log_message=nil
      begin
        logger = @logger
        @logger = nil      
        t = Time.now
        send_message_without_time operation, message, log_message
      ensure
        logger.debug("MONGODB (#{Time.now - t}) #{log_message || message}") if logger
        @logger = logger
      end
    end
    alias_method_chain :send_message, :time
  
    def send_message_with_safe_check_with_time operation, message, db_name, log_message=nil    
      begin
        logger = @logger
        @logger = nil      
        t = Time.now
        send_message_with_safe_check_without_time operation, message, db_name, log_message
      ensure
        logger.debug("MONGODB (#{Time.now - t}) #{log_message || message}") if logger
        @logger = logger
      end
    end
    alias_method_chain :send_message_with_safe_check, :time
  
    def receive_message_with_time operation, message, log_message=nil, socket=nil
      begin
        logger = @logger
        @logger = nil      
        t = Time.now
        receive_message_without_time operation, message, log_message, socket
      ensure
        logger.debug("MONGODB (#{Time.now - t}) #{log_message || message}") if logger
        @logger = logger
      end
    end
    alias_method_chain :receive_message, :time
  end
end