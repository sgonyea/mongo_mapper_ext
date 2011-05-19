require 'mongo_mapper/spec_helper'

describe "MongoMapper micelaneous" do
  with_mongo_mapper
  
  after(:all){remove_constants %w(UpsertSample AsStringSample TranslationCheck)}    
    
  describe "i18n" do
    it "should translate error messages" do
      class ::TranslationCheck
        include MongoMapper::Document

        key :name, String
        validates_uniqueness_of :name
      end

      TranslationCheck.destroy_all
      TranslationCheck.create! name: 'a'
      t = TranslationCheck.new name: 'a'
      t.should_not be_valid
      t.errors[:name].first.should =~ /already been taken/
    end
  end
    
  describe "handy upsert" do
    class ::UpsertSample
      include MongoMapper::Document
      include MongoMapper::Plugins::Micelaneous
      
      key :counter, Integer, default: 1
    end  
    
    before do 
      @model = UpsertSample.create!
    end
  
    it "class upsert" do
      UpsertSample.upsert!({id: @model.id}, :$inc => {counter: 1})
      @model.reload
      @model.counter.should == 2
    end
  
    it "model upsert" do
      @model.upsert! :$inc => {counter: 1}
      @model.reload
      @model.counter.should == 2
    end
  end
  
  describe "as_string" do
    before do
      @convertors = MongoMapper::Plugins::AttributeConvertors::ClassMethods::ATTRIBUTE_CONVERTORS
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
        include MongoMapper::Plugins::Micelaneous
        
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