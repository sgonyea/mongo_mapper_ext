# 
# Changing filename format from <version>_<filename_with_extension> to <name>.<version>.<extension>
# 
CarrierWave::Uploader::Versions.class_eval do
  def full_filename(for_file)
    name = super
    if version_name
      ext = File.extname name
      base = File.basename name, ext
      "#{base}.#{version_name}#{ext}"
    else
      name
    end    
  end

  def full_original_filename
    name = super
    if version_name
      ext = File.extname name
      base = File.basename name, ext
      "#{base}.#{version_name}#{ext}"
    else
      name
    end
  end
end
