module MongoMapper::Plugins::Micelaneous
  extend ActiveSupport::Concern
  
  module InstanceMethods
    def upsert! *args
      self.class.upsert!({id: id}, *args)
    end
    
    def exist?
      self.class.find(id) != nil
    end
  end
  
  module ClassMethods                
    # 
    # model_name
    # 
    def model_name *args
      if args.empty?
        @model_name ||= ::ActiveModel::Name.new self, self.alias
      else
        @model_name = ::ActiveModel::Name.new self, args.first
      end          
    end
    
    
    # 
    # Sequentiall :all for big collection
    # 
    def all_sequentially &block
      page, per_page = 1, 5
      begin
        results = paginate(page: page, per_page: per_page, order: '_id asc')
        results.each{|o| block.call o}
        page += 1
      end until results.blank? or results.size < per_page
    end
    
    
    # 
    # shortcut for upsert
    # 
    def upsert! query, *args
      query[:_id] = query.delete :id if query.include? :id
      collection.upsert! query, *args          
    end
  end
  
end