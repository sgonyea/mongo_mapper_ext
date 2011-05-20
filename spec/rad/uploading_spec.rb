require 'rad/spec_helper'

describe "Uploading" do  
  with_tmp_spec_dir
  with_mongo_mapper
  with_files  
  
  before :all do
    class ShipUploader < Models::FileUploader      
    end
    
    class Ship
      include MongoMapper::Document

      key :name
      validates_uniqueness_of :name
      
      file_key :image, ShipUploader
    end                
  end  
  after(:all){remove_constants :Ship, :ShipUploader}  
  
  it "should upload images" do    
    ship = nil
    File.open "#{spec_dir}/ship.jpg" do |f|
      ship = Ship.new image: f
      ship.save!
    end
    ship.image.url.should =~ /\/ship\.jpg/
    ship.image_filename.should =~ /ship\.jpg/
    ship.image.path.should =~ /\/ship\.jpg/
  end
  
  it "should preserve spaces and unicode characters in filename" do
    File.open "#{spec_dir}/файл с пробелами.txt" do |f|
      ship = Ship.new image: f

      ship.image.url.should =~ /\/файл с пробелами\.txt/
      ship.image.filename =~ /файл с пробелами\.txt/
      ship.image.path =~ /\/файл с пробелами\.txt/
    
      # ship.smart_url.should =~ /files\/file with spaces\/file with spaces\.txt\?\d/
      # f.smart_url.should =~ /files\/data\/ship\?\d+/
      # f.smart_url(:icon).should =~ /images\/mime\/dat_icon\.png/
      # f.smart_url(:thumb).should =~ /images\/mime\/dat_thumb\.png/
    end
  end
end