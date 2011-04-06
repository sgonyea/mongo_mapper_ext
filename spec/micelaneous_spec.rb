require 'spec_helper'

require "mongo_mapper_ext/micelaneous"
require "mongo_mapper_ext/plugins/micelaneous"

describe "MongoMapper micelaneous" do
  before :all do
    @db = Mongo::Connection.new.db('test')
    MongoMapper.database = 'test'
  end
  
  after :all do
    remove_constants %w(UpsertSample AsStringSample)
  end  
  
  before do
    @db.collection('test').drop
    @coll = @db.collection('test')
  end    
    
  it "upsert should update" do
    id = @coll.save count: 2
    @coll.upsert id, :$inc => {count: 1}
    @coll.find(_id: id).first['count'].should == 3
  end
  
  it "upsert should set" do
    id = @coll.save({})
    @coll.upsert id, :$inc => {count: 1}
    @coll.find(_id: id).first['count'].should == 1
  end
    
  describe "handy upsert" do
    class ::UpsertSample
      include MongoMapper::Document
      plugin MongoMapper::Plugins::Micelaneous
      
      key :counter, Integer, default: 1
    end  
    
    before do 
      @model = UpsertSample.create!
    end
  
    it "class upsert" do
      UpsertSample.upsert @model.id, :$inc => {counter: 1}
      @model.reload
      @model.counter.should == 2
    end
  
    it "model upsert" do
      @model.upsert :$inc => {counter: 1}
      @model.reload
      @model.counter.should == 2
    end
  end
  
  describe "as_string" do
    before do
      @convertors = MongoMapper::Plugins::Micelaneous::ClassMethods::STRING_CONVERTORS
      @convertors[:test_convertor] = {
        from_string: -> s {"from_string: #{s}"},
        to_string:   -> v {"to_string: #{v}"}
      }
    end
    
    it ":line convertor" do      
      v = ['a', 'b']
      str_v = 'a, b'
      @convertors[:line][:from_string].call(str_v).should == v
      @convertors[:line][:to_string].call(v).should == str_v
    end
    
    it ":yaml convertor" do
      v = {'a' => 'b'}
      str_v = v.to_yaml.strip
      
      @convertors[:yaml][:from_string].call(str_v).should == v
      @convertors[:yaml][:to_string].call(v).should == str_v
    end
    
    it ":json convertor" do
      v = {'a' => 'b'}
      str_v = v.to_json.strip
      @convertors[:json][:from_string].call(str_v).should == v
      @convertors[:json][:to_string].call(v).should == str_v
    end
    
    it ":key extension" do
      class ::AsStringSample
        include MongoMapper::Document
        plugin MongoMapper::Plugins::Micelaneous
        
        key :key, String, as_string: :test_convertor
        key :protected_key, String, as_string: :test_convertor, protected: true
      end
    
      o = AsStringSample.new
      
      # get
      o.key_as_string.should == 'to_string: '
      o.key = 'value'
      o.clear_cache
      o.key_as_string.should == 'to_string: value'
      
      # set
      o.key_as_string = ''
      o.key.should == 'from_string: '
      o.key_as_string = 'value'
      o.key.should == 'from_string: value'
      
      # mass assignment
      o.key = ''
      o.update_attributes key_as_string: 'value'
      o.key.should == 'from_string: value'
      
      # protection
      o.protected_key = ''
      o.update_attributes protected_key_as_string: 'value'
      o.protected_key.should == ''
    end
  end
end