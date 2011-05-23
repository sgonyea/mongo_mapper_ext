require 'carrier_wave/spec_helper'

describe "MongoMapper & CarrierWave" do  
  with_mongo_mapper
  with_tmp_spec_dir
  
  before :all do
    class PlaneImageUploader < CarrierWave::Uploader::Base
      require 'carrierwave/processing/mini_magick'

      include CarrierWave::MiniMagick      
    
      storage :file
    
      version :icon do
        process convert: :png
        process resize_to_fit: [50, 50]
      end
    
      class << self
        attr_accessor :store_dir
      end      
    
      def store_dir
        PlaneImageUploader.store_dir
      end
    
      def root
        PlaneImageUploader.store_dir
      end
    end        
  end
  after(:all){remove_constants :PlaneImageUploader}
  
  before do
    PlaneImageUploader.store_dir = "#{spec_dir}/data"
    @file = File.new "#{spec_dir}/plane.jpg"
  end
  after{@file.close}
  
  describe "Document" do
    before :all do
      class Plane
        include MongoMapper::Document
  
        mount_uploader :image, PlaneImageUploader
      end        
    end
    after(:all){remove_constants :Plane}
  
    it "basic" do
      plane = Plane.create! image: @file
      plane.image.current_path.should =~ /\/plane.jpg/
      File.should exist("#{spec_dir}/data/plane.jpg")
    end
    
    it "should works without model" do
      # writing
      uploader = PlaneImageUploader.new
      uploader.store!(@file)
      uploader.identifier.should == 'plane.jpg'
      uploader.url.should == '/plane.jpg'
      uploader.icon.url.should == '/plane.icon.jpg'
      File.should exist("#{spec_dir}/data/plane.icon.jpg")
      
      # reading
      uploader = PlaneImageUploader.new
      uploader.retrieve_from_store! 'plane.jpg'
      uploader.url.should == '/plane.jpg'
      uploader.icon.url.should == '/plane.icon.jpg'
      
      # destroying
      uploader = PlaneImageUploader.new
      uploader.retrieve_from_store! 'plane.jpg'
      uploader.remove!
      File.should_not exist("#{spec_dir}/data/plane.icon.jpg")
    end
  
    it "path format" do
      plane = Plane.create! image: @file
      plane.image.url.should == '/plane.jpg'
      plane.image.icon.url.should =~ /\/plane\.icon\.jpg/
    
      plane.image.icon.current_path.should =~ /\/plane\.icon\.jpg/
      File.should exist("#{spec_dir}/data/plane.icon.jpg")
    end
  end
  
  describe "EmbeddedDocument" do
    before :all do
      class PlaneImage
        include MongoMapper::EmbeddedDocument
        
        file_key :image, PlaneImageUploader
      end
      
      class Plane
        include MongoMapper::Document
        
        has_many :images, class_name: 'PlaneImage'                
      end        
    end
    after(:all){remove_constants :Plane, :PlaneImage, :PlaneImageUploader}
  
    it "basic"
    # do
    #   plane = Plane.create! images: [PlaneImage.new(image: @file)]
    #   plane.images.first.image.current_path.should =~ /\/plane.jpg/
    #   File.should exist("#{spec_dir}/data/plane.jpg")
    # end
  
    it "path format"
    # do
    # end
  end
end