# # 
# # mount_uploaders
# # 
# module MongoMapper::Plugins::MountUploaders
#   extend ActiveSupport::Concern
#   
#   class FileHelper
#     attr_reader :data
#     def initialize data
#       data.must_be.a String, File, Hash
#       if data.is_a?(Hash)
#         data.must.include('filename') 
#         data.must.include('tempfile')
#       end
#       @data = data      
#     end
#     
#     def real_file?
#       data.is_a?(File) or data.is_a?(Hash) 
#     end
#     
#     def file_name
#       real_file? 
#     end
#   end
#   
#   module InstanceMethods
#     def set_uploaders attr_name, files
#       before = get_uploaders attr_name
#       after = files
#       
#       # selecting File and HTTP TempFile
#       added = files.select{|file| FileHelper.new(file).real_file?}
#       deleted = files.
#       
#       
#       added = after - before
#       deleted = before - after
#   
#       added.each do |name|
#         if tag = Tag.find_by_name(name)
#           tag.update_count!
#         else
#           tag = Tag.new name: name
#           tag.count = 1 
#           tag.save!
#         end
#       end
#     
#       deleted.each do |name|
#         if tag = Tag.find_by_name(name)
#           tag.update_count! 
#           tag.destroy if tag.count == 0
#         end
#       end
#       
#       
#       # tags.join(", ")
#     end
# 
#     def get_uploaders attr_name
#       # self.tags = tags_as_string.split(Tag::TAG_LIST_DELIMITER).collect{|name| name.strip}.sort
#     end
# 
#     after_save :update_tags
#     def update_tags
#       return unless changed.include? 'tags'
#   
#       before, after = changes['tags']
#       added = after - before
#       deleted = before - after
#   
#       added.each do |name|
#         if tag = Tag.find_by_name(name)
#           tag.update_count!
#         else
#           tag = Tag.new name: name
#           tag.count = 1 
#           tag.save!
#         end
#       end
#     
#       deleted.each do |name|
#         if tag = Tag.find_by_name(name)
#           tag.update_count! 
#           tag.destroy if tag.count == 0
#         end
#       end
#     end
#     protected :update_tags
# 
#     after_destroy :delete_tags
#     def delete_tags
#       raise "Can't destroy item with changed tags!" if changed.include? 'tags'
#   
#       tags.each do |name|
#         if tag = Tag.find_by_name(name)
#           tag.update_count! 
#           tag.destroy if tag.count == 0
#         end
#       end
#     end
#     protected :delete_tags
#     
#     protected
#       def parse_file_name obj
#         if obj.is_a
#       end
#       
#       def 
#   end
#   
#   module ClassMethods
#     include ::CarrierWave::Mount
# 
#     def mount_uploaders(column, uploader, options={}, &block)
#       options[:mount_on] ||= "#{column}_filename"
#       name = options[:mount_on]
#       key name
# 
#       # super
#       # 
#       # alias_method :read_uploader, :read_attribute
#       # alias_method :write_uploader, :write_attribute
#       # 
#       # include ::CarrierWave::Validations::ActiveModel
#       # 
#       # validates_integrity_of  column if uploader_option(column.to_sym, :validate_integrity)
#       # validates_processing_of column if uploader_option(column.to_sym, :validate_processing)
#       # 
#       # after_save "store_#{column}!".to_sym
#       # before_save "write_#{column}_identifier".to_sym
#       # after_destroy "remove_#{column}!".to_sym
#     end
#     alias_method :file_keys, :mount_uploaders
#   end
# end