require 'carrierwave/validations/active_model'

# 
# Hacks
# 
CarrierWave::SanitizedFile.class_eval do
  def sanitize_regexp
    /[^[:word:]\.\-\+\s_]/i
  end
end

CarrierWave::Uploader::Cache.class_eval do
  def original_filename=(filename)
    raise CarrierWave::InvalidParameter, "invalid filename" unless filename =~ /\A[[:word:]\.\-\+\s_]+\z/i
    @original_filename = filename
  end
end


# 
# mount_uploader
# 
module MongoMapper
  module Plugins
    module CarrierWave
      extend ActiveSupport::Concern
      
      module ClassMethods
        include ::CarrierWave::Mount
        ##
        # See +CarrierWave::Mount#mount_uploader+ for documentation
        #
        def mount_uploader(column, uploader, options={}, &block)
          define_key column, uploader, options

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
        
        protected
          def define_key column, uploader, options
            options[:mount_on] ||= "#{column}_filename"
            name = options[:mount_on]
            key name
            
            # # not allowin
            # before_save do |model|
            #   filename = model.send(name).filename
            #   
            # end
            # rad.extension(:kit_carrierwave, self){validates_uniqueness_of name}
            #             
            # ensure_index name
          end
      end
    end
  end
end

MongoMapper::Document.include MongoMapper::Plugins::CarrierWave