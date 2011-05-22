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
    Object.send :remove_const, :AnObject, :Plane, :PlaneImage if Object.const_defined? :AnObject
  end
    
  it 'a very old bug, probably fixed by now' do
    o = AnObject.new
    o.owner_name = 'user'
    o.save!
    
    # o = AnObject.first # don't use reload, it willn't catch this error
    o.viewers.should == %w{user}
  end
  
  it "strange behaviour of EmbeddedDocument" do
    class PlaneImage
      include MongoMapper::EmbeddedDocument
      
      key :data, String      
      alias_method :original_data=, :data=
      def data= value
        $id_before_save = object_id
        self.original_data = value
      end      
      
      after_save :check_my_id
      def check_my_id
        $id_after_save = object_id
      end
    end
    class Plane
      include MongoMapper::Document
      has_many :images, class_name: 'PlaneImage'
    end    
    
    Plane.create! images: [PlaneImage.new(data: 'some image')]
    $id_before_save.should == $id_after_save
  end
end