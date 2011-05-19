require 'carrier_wave/spec_helper'

describe "MongoMapper & CarrierWave" do  
  with_mongo_mapper
  with_tmp_spec_dir
  
  before :all do
    class PlaneUploader < CarrierWave::Uploader::Base
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
        PlaneUploader.store_dir
      end
      
      def root
        PlaneUploader.store_dir
      end
    end
    
    class Plane
      include MongoMapper::Document
  
      mount_uploader :image, PlaneUploader
    end        
  end
  after(:all){remove_constants :Plane, :PlaneUploader}
  
  before do
    PlaneUploader.store_dir = "#{spec_dir}/data"
    @file = File.new "#{spec_dir}/plane.jpg"
  end
  after{@file.close}
  
  it "basic" do
    plane = Plane.create! image: @file
    plane.image.current_path.should =~ /\/plane.jpg/
    File.should exist("#{spec_dir}/data/plane.jpg")
  end
  
  it "path format" do
    plane = Plane.create! image: @file
    plane.image.url.should == '/plane.jpg'
    plane.image.icon.url.should =~ /\/plane\.icon\.jpg/
    
    plane.image.icon.current_path.should =~ /\/plane\.icon\.jpg/
    File.should exist("#{spec_dir}/data/plane.icon.jpg")
  end
end