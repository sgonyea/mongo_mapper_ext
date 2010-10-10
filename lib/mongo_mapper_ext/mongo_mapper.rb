MongoMapper.class_eval do
  class << self
    
    def logger
      # return @logger ||= Logger.new(nil) if defined?(Spec)
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