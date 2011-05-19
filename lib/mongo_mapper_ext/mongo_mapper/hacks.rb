# 
# Allow to specify different model name than class name
# 
ActiveModel::Name.class_eval do
  def initialize klass, name = nil
    name ||= klass.name
    
    super name
    
    @klass = klass
    @singular = ActiveSupport::Inflector.underscore(self).tr('/', '_').freeze
    @plural = ActiveSupport::Inflector.pluralize(@singular).freeze
    @element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)).freeze
    @human = ActiveSupport::Inflector.humanize(@element).freeze
    @collection = ActiveSupport::Inflector.tableize(self).freeze
    @partial_path = "#{@collection}/#{@element}".freeze
    @i18n_key = ActiveSupport::Inflector.underscore(self).tr('/', '.').to_sym
  end
  
  # def initialize(klass)
  #   super(klass.name)
  #   @klass = klass
  #   @singular = ActiveSupport::Inflector.underscore(self).tr('/', '_').freeze
  #   @plural = ActiveSupport::Inflector.pluralize(@singular).freeze
  #   @element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)).freeze
  #   @human = ActiveSupport::Inflector.humanize(@element).freeze
  #   @collection = ActiveSupport::Inflector.tableize(self).freeze
  #   @partial_path = "#{@collection}/#{@element}".freeze
  #   @i18n_key = ActiveSupport::Inflector.underscore(self).tr('/', '.').to_sym
  # end
end


# 
# Logger
# 
MongoMapper.class_eval do
  class << self
    attr_writer :logger
  end
end

Mongo::Connection.class_eval do
  attr_writer :logger
end


# 
# Silence Logger
# 
MongoMapper.class_eval do
  def self.silince_logger &block
    logger, nil_logger = self.logger, Logger.new(nil)
    
    begin  
      MongoMapper.logger = nil_logger
      connections.each{|name, connection| connection.logger = nil_logger}
      block.call
    ensure
      MongoMapper.logger = logger
      connections.each{|name, connection| connection.logger = logger}
    end
  end
end


# 
# Silent index creation
# 
MongoMapper::Plugins::Indexes::ClassMethods.class_eval do
  def ensure_index_with_silent_logger *a
    MongoMapper.silince_logger{ensure_index_without_silent_logger *a}
  end  
  alias_method_chain :ensure_index, :silent_logger
end