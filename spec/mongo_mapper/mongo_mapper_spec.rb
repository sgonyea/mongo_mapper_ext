require 'mongo_mapper/spec_helper'

describe "Special test to check some errors in the MongoMapper itself" do  
  before :all do
    MongoMapper.database = 'test'
    
    class ::AnObject
      include MongoMapper::Document
      
      key :owner_name, String
      key :viewers, Array
      
      def owner_name= owner_name
        viewers.delete self.owner_name
        viewers << owner_name        
        # write_attribute :owner_name, owner_name
        super owner_name
        owner_name
      end
    end
  end
  
  after :all do
    Object.send :remove_const, :AnObject if Object.const_defined? :AnObject
  end
    
  it do
    o = AnObject.new
    o.owner_name = 'user'
    o.save!
    
    # o = AnObject.first # don't use reload, it willn't catch this error
    o.viewers.should == %w{user}
  end
end