module MongoMapper::Plugins::CustomScope
  extend ActiveSupport::Concern
  
  module ClassMethods
    def query options = {}
      super default_scope_options.merge(options)
    end
    
    def find_one options = {}
      super default_scope_options.merge(options)
    end

    def find_many options = {}
      super default_scope_options.merge(options)
    end
    
    def count options={}
      super default_scope_options.merge(options)
    end
    
    def with_exclusive_scope options = {}, &block
      raise "exclusive scope already applied, can't apply it twice!" if Thread.current['mm_with_exclusive_scope']
      
      before = Thread.current['mm_with_exclusive_scope']
      begin
        Thread.current['mm_with_exclusive_scope'] = options
        block.call if block
      ensure
        Thread.current['mm_with_exclusive_scope'] = before
      end
    end
    
    def with_scope options = {}, &block
      raise "exclusive scope already applied, can't apply it twice!" if Thread.current['mm_with_exclusive_scope']
      
      before = Thread.current['mm_with_scope']
      begin
        options = before.merge options if before
        Thread.current['mm_with_scope'] = options
        block.call if block
      ensure
        Thread.current['mm_with_scope'] = before
      end
    end
    
    protected
      def default_scope options = nil, &block          
        raise "invalid option (#{options.inspect})!" if options and !options.is_a?(Hash)
        self.write_inheritable_attribute(:default_scope, (options || block))
      end
              
    private
      def default_scope_options
        default_scope = self.read_inheritable_attribute(:default_scope)
        
        exclusive_options = Thread.current['mm_with_exclusive_scope']
        return exclusive_options if exclusive_options
        
        options = if default_scope
          if default_scope.respond_to? :call
            default_scope.call self
          else
            default_scope
          end
        else
          {}
        end
        
        if scope_options = Thread.current['mm_with_scope']
          options = options.merge scope_options
        end
        
        options
      end
  end
  
end