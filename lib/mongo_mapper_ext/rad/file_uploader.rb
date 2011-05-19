require 'carrierwave/processing/mini_magick'

class Models::FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  
  storage rad.config.fs.type(:file)

  # def sanitize_regexp
  #   /[^[:word:]\.\-\+\s_]/i
  # end

  def file_path
    "#{rad.config.fs.prefix('/fs')}/system/#{model.class.model_name.underscore}/#{model.id}"
  end

  def store_dir
    "#{root}#{file_path}"
  end

  def extension_white_list
    [/.*/]
  end

  def cache_dir; rad.config.fs.cache_path! end  
  def root; rad.config.fs.path! end  
end