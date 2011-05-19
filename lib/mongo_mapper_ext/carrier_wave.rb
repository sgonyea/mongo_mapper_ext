require 'carrierwave'
require 'carrierwave/validations/active_model'

require 'mongo_mapper_ext/mongo_mapper'

%w(
  fixes
  micelaneous
  mongo_mapper/plugins/carrier_wave
).each{|f| require "mongo_mapper_ext/carrier_wave/#{f}"}

MongoMapper::Document.send :include, MongoMapper::Plugins::CarrierWave