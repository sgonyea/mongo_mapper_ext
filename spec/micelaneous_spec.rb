require 'spec_helper'

require "mongo_mapper_ext/micelaneous"
require "mongo_mapper_ext/plugins/micelaneous"

describe "MongoMapper micelaneous" do
  before :all do
    @db = Mongo::Connection.new.db('test')
    MongoMapper.database = 'test'
  end
  
  before :each do
    @db.collection('test').drop
    @coll = @db.collection('test')
  end
    
  it "upsert should update" do
    id = @coll.save :count => 2
    @coll.upsert id, :$inc => {:count => 1}
    @coll.find(:_id => id).first['count'].should == 3
  end
  
  it "upsert should set" do
    id = @coll.save({})
    @coll.upsert id, :$inc => {:count => 1}
    @coll.find(:_id => id).first['count'].should == 1
  end
    
  describe "handy upsert" do
    class ::UpsertSample
      include MongoMapper::Document
      plugin MongoMapper::Plugins::Micelaneous
      
      key :counter, Integer, :default => 1
    end  
    
    before :each do 
      @model = UpsertSample.create!
    end
  
    it "class upsert" do
      UpsertSample.upsert @model.id, :$inc => {:counter => 1}
      @model.reload
      @model.counter.should == 2
    end
  
    it "model upsert" do
      @model.upsert :$inc => {:counter => 1}
      @model.reload
      @model.counter.should == 2
    end
  end
end