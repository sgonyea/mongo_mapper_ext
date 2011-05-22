require 'mongo_mapper_ext/gems'
require 'mongo_mapper'

require 'mongo_mapper_ext/mongo_db'


%w(
  fixes
  hacks
  support
  
  migration  
  view_helpers
  
  plugins/attribute_cache
  plugins/attribute_convertors
  plugins/belongs_to_with_counter_cache
  plugins/custom_scope
  plugins/db_config  
  plugins/micelaneous  
).each{|file| require "mongo_mapper_ext/mongo_mapper/#{file}"}


# 
# Default plugins
# 
[
  MongoMapper::Plugins::CustomScope, 
  MongoMapper::Plugins::AttributeCache, 
  MongoMapper::Plugins::AttributeConvertors, 
  MongoMapper::Plugins::BelongsToWithCounterCache, 
  MongoMapper::Plugins::Micelaneous, 
  MongoMapper::Plugins::DbConfig
].each{|plugin| ::MongoMapper::Document.send :include, plugin}
  
  
# 
# Attribute protection
# 
MongoMapper::Document.included do
  attr_protected :id, :_id, :_type, :created_at, :updated_at
end


# 
# Locales
# 
dir = File.expand_path "#{__FILE__}/../../.."
I18n.load_path += Dir["#{dir}/config/locales/**/*.{rb,yml}"]