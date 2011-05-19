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
