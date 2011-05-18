require 'spec_helper'

require "mongo_mapper_ext"
require "mongo_mapper_ext/spec"

describe "MongoMapper & CarrierWave" do  
  with_mongo_mapper
  with_test_database
  with_tmp_spec_dir
  
  before :all do
    MongoMapper.database = 'test'    
    
    class PlaneUploader < CarrierWave::Uploader::Base
      storage :file
      
      class << self
        attr_accessor :store_dir
      end      
      
      def store_dir
        self.class.store_dir
      end
    end
    
    class Plane
      include MongoMapper::Document
  
      # key :image, String
      mount_uploader :image, PlaneUploader
    end        
  end
  
  before do
    PlaneUploader.store_dir = "#{spec_dir}/data"
  end
  
  after :all do
    remove_constants :Plane, :PlaneUploader
  end
  
  it "basic" do
    plane = Plane.new
    File.open "#{spec_dir}/plane.jpg" do |f|
      plane.image = f
      plane.save!
    end
    
    plane.image.current_path.should == '/tmp/carrierwave_spec/data/plane.jpg'
    File.should exist("#{spec_dir}/data/plane.jpg") #.to_file.exist?.should be_true
  end
end