require 'mongo_mapper_ext/gems'
require 'mongo_mapper'

require 'mongo_mapper_ext/mongo_db'

%w(
  fixes
  hacks
  support
  
  migration  
  view_helpers  
  logging
  
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
module MongoMapper::Plugins
  [CustomScope, AttributeCache, AttributeConvertors, BelongsToWithCounterCache, Micelaneous, DbConfig].each do |plugin|
    ::MongoMapper::Document.send :include, plugin
  end
end
  
  
# 
# Attribute protection
# 
MongoMapper::Document.included do
  attr_protected :id, :_id, :_type, :created_at, :updated_at
end


# 
# Locales
# 
dir = __FILE__.dirname
I18n.load_path += Dir["#{dir}/mongo_mapper/locales/**/*.{rb,yml}"]