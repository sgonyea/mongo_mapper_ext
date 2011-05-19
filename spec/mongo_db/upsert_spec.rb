require 'mongo_db/spec_helper'

describe "MongoMapper micelaneous" do
  before do
    connection = Mongo::Connection.new.db('test')
    @collection = connection.collection('test')
  end
  
  it "upsert should update" do
    id = @collection.save count: 2
    @collection.upsert!({_id: id}, :$inc => {count: 1})
    @collection.find(_id: id).first['count'].should == 3
  end

  it "upsert should set" do
    id = @collection.save({})
    @collection.upsert!({_id: id}, :$inc => {count: 1})
    @collection.find(_id: id).first['count'].should == 1
  end
end