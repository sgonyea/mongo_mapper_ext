#
# upsert
# 
Mongo::Collection.class_eval do
  def upsert id, opt
    opt.size.must == 1
    opt.must_be.a Hash
    opt.values.first.must_be.a Hash
    
    update({:_id => id}, opt, {:upsert => true, :safe => true})
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