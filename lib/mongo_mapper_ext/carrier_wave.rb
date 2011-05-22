require 'carrierwave'
require 'carrierwave/validations/active_model'

require 'mongo_mapper_ext/mongo_mapper'

%w(
  fixes
  micelaneous
  mongo_mapper/plugins/mount_uploader
  mongo_mapper/plugins/mount_uploaders
).each{|f| require "mongo_mapper_ext/carrier_wave/#{f}"}

MongoMapper::Document.send :include, MongoMapper::Plugins::MountUploader
MongoMapper::EmbeddedDocument.send :include, MongoMapper::Plugins::MountUploader