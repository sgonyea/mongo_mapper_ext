module MongoMapper
  module Plugins
    module AttributesCache
      extend ActiveSupport::Concern
      
      module InstanceMethods
        def cache
          @cache ||= {}
        end

        def clear_cache
          @cache = {}
        end

        def reload
          @cache.clear if @cache
          super
        end
      end
      
    end
  end
end