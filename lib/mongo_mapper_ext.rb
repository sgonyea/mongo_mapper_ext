require 'mongo_mapper_ext/gems'

require 'mongo_mapper'
require 'carrierwave'

%w(
  micelaneous
).each{|file| require "mongo_db_ext/#{file}"}

%w(
  hacks/fixes
  hacks/active_model
  
  migration
  mongo_mapper
  view_helpers  
  logging
  
  plugins/db_config
  plugins/custom_scope
  plugins/attribute_cache
  plugins/carrierwave
  plugins/attribute_convertors
  plugins/micelaneous
  plugins/belongs_to_with_counter_cache
).each{|file| require "mongo_mapper_ext/#{file}"}

# 
# Default plugins and settings
# 
module MongoMapper::Plugins
  [CustomScope, AttributeCache, AttributeConvertors, BelongsToWithCounterCache, Micelaneous, CarrierWave, DbConfig].each do |plugin|
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
dir = File.expand_path("#{__FILE__}/../..")
I18n.load_path += Dir["#{dir}/locales/**/*.{rb,yml}"]