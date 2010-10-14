require 'spec_helper'

require "mongo_mapper_ext"
require "mongo_mapper_ext/spec/helper"

describe "MongoMapper Migration" do
  with_mongo_mapper
  
  Migration = MongoMapper::Migration  
  
  before :all do
    MongoMapper.logger = Logger.new(nil)
    MongoMapper.db_config = {
      'global' => {'name' => 'global_test'},
      'accounts' => {'name' => "accounts_test"}
    }
    
    class ::Sample
      include MongoMapper::Document
      use_database :global

      key :name, String
    end
        
    # MongoMapper.call_deferred
    Migration.logger = nil        
  end

  after :all do
    Object.send :remove_const, :Sample if Object.const_defined? :Sample    
  end
  
  before :each do
    Migration.definitions.clear
  end
  
  it "Shouldn't update if versions are the same" do
    Migration.update(:global, 0).should be_false
  end
  
  it "migration should provide access to current database" do
    Sample.count.should == 0    
    Migration.define :global, 1 do |m|
      m.up do |db|
        Sample.create :name => 'name'
        coll = db.collection 'samples'
        coll.find.count.should == 1
      end
    end
  
    Migration.update(:global, 1).should be_true    
    Sample.count.should == 1
  end

  it "increase_db_version" do
    Sample.count.should == 0
    Migration.define :global, 1 do |m|
      m.up{Sample.create :name => 'name'}
    end
  
    Migration.update(:global, 1).should be_true    
    Sample.count.should == 1
    Migration.metadata(MongoMapper.databases[:global]).version.should == 1
  end
  
  it "decrease_db_version" do    
    Migration.define :global, 1 do |m|
      m.up{Sample.create :name => 'name'}
      m.down{Sample.destroy_all}
    end
    Migration.update(:global, 1).should be_true
    Sample.count.should == 1
  
    Migration.update(:global, 0).should be_true
    Sample.count.should == 0
    Migration.metadata(MongoMapper.databases[:global]).version.should == 0
  end
    
end