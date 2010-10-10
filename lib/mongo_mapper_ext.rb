gem 'mongo_mapper', '>=0.8'
require 'mongo_mapper'


[
  'hacks/fixes',
  'hacks/time_measuring',
  'migration',
  'mongo_mapper',
  'view_helpers',
  'db_config',
  'micelaneous',
  
  'plugins/default_scope',
  # 'plugins/db_config',  
  'plugins/attributes_cache',
  'plugins/micelaneous',  
].each do |file|
  require "mongo_mapper_ext/#{file}"
end

module CommonPluginsAddition
  def self.included(model)
    model.plugin MongoMapper::Plugins::DefaultScope
    # model.plugin MongoMapper::Plugins::DbConfig
    model.plugin MongoMapper::Plugins::AttributesCache
    model.plugin MongoMapper::Plugins::Micelaneous
    
    model.attr_protected :id, :_id, :_type, :created_at, :updated_at
  end
end
MongoMapper::Document.append_inclusions(CommonPluginsAddition)