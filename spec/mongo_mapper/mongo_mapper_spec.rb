require 'mongo_mapper'

describe "Special test to check some errors in the MongoMapper" do  
  before :all do
    MongoMapper.database = 'test'
  end
  
  after :all do
    Object.send :remove_const, :Plane, :PlaneImage if Object.const_defined? :AnObject
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