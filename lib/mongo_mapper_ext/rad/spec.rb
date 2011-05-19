require 'mongo_mapper_ext/rad'

require 'mongo_mapper_ext/mongo_mapper/spec'

# 
# Files
# 
rspec do
  class << self
    def with_files
      path, cache_path = '/tmp/spec_fs', '/tmp/spec_fs_cache'
      
      before do
        rad.config.merge!({fs: {path: path, cache_path: cache_path}}, override: true)
        
        Models::FileUploader.storage :file
        
        CarrierWave.configure do |config|          
          config.storage = :file
          config.enable_processing = false
          
          config.cache_dir = rad.config.fs.cache_path!
          config.root = rad.config.fs.path!
        end
      end
      
      before do
        path.to_dir.destroy
        cache_path.to_dir.destroy
      end
      
      after do
        path.to_dir.destroy
        cache_path.to_dir.destroy
      end
    end    
  end
end