require 'mongo_mapper_ext/gems'
require 'mongo_mapper'

[
  'hacks/fixes',
  'hacks/time_measuring',
  'hacks/active_model',
  
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

# 
# Default plugins and settings
# 

MongoMapper::Document.plugin MongoMapper::Plugins::DefaultScope
# MongoMapper::Document.plugin MongoMapper::Plugins::DbConfig
MongoMapper::Document.plugin MongoMapper::Plugins::AttributesCache
MongoMapper::Document.plugin MongoMapper::Plugins::Micelaneous
  
MongoMapper::Document.included do
  attr_protected :id, :_id, :_type, :created_at, :updated_at
end

# 
# Locales
# 
dir = File.expand_path("#{__FILE__}/../..")
I18n.load_path += Dir["#{dir}/locales/**/*.{rb,yml}"]