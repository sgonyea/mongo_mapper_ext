# 
# mount_uploader
# 
module MongoMapper::Plugins::MountUploader
  extend ActiveSupport::Concern
  
  module ClassMethods
    include ::CarrierWave::Mount

    def mount_uploader(column, uploader, options={}, &block)
      options[:mount_on] ||= "#{column}_filename"
      name = options[:mount_on]
      key name

      super

      alias_method :read_uploader, :read_attribute
      alias_method :write_uploader, :write_attribute

      include ::CarrierWave::Validations::ActiveModel

      validates_integrity_of  column if uploader_option(column.to_sym, :validate_integrity)
      validates_processing_of column if uploader_option(column.to_sym, :validate_processing)

      after_save "store_#{column}!".to_sym
      before_save "write_#{column}_identifier".to_sym
      after_destroy "remove_#{column}!".to_sym
    end
    alias_method :file_key, :mount_uploader
  end
end