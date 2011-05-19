require 'mongo_mapper/spec_helper'

describe "MongoMapper Default Scope" do
  with_mongo_mapper
  
  before do 
    class ::ScopeSample
      include MongoMapper::Document
      include MongoMapper::Plugins::CustomScope
      
      key :name, String
      key :_type, String
    end
    
    ScopeSample.delete_all
    ScopeSample.create! name: 'a'
    ScopeSample.create! name: 'b'
  end
  
  after(:all){remove_constants :ScopeSample}
    
  it "should not affect objects without default_scope" do
    ScopeSample.count.should == 2
    ScopeSample.all.count.should == 2
  end
  
  it "default_scope" do
    ScopeSample.send :default_scope, name: 'a'
    ScopeSample.count.should == 1
    ScopeSample.all.count.should == 1
    ScopeSample.first.name.should == 'a'
  end
  
  it "default_scope as block" do
    ScopeSample.send :default_scope do
      {name: 'a'}
    end
    ScopeSample.count.should == 1
    ScopeSample.all.count.should == 1
    ScopeSample.first.name.should == 'a'
  end
  
  it "default_scope should be inherited" do    
    ScopeSample.send :default_scope, name: 'a'
    class ScopeSampleAncestor < ScopeSample
    end
    
    ScopeSampleAncestor.create! name: 'a'
    ScopeSampleAncestor.create! name: 'b'

    ScopeSampleAncestor.count.should == 1
    ScopeSampleAncestor.all.count.should == 1
    ScopeSampleAncestor.first.name.should == 'a'
  end
  
  it "ancestors should be able to override default_scope" do
    ScopeSample.send :default_scope, name: 'a'
    class ScopeSampleAncestor2 < ScopeSample
      default_scope name: 'b'
    end
    
    ScopeSampleAncestor2.create! name: 'a'
    ScopeSampleAncestor2.create! name: 'b'
        
    ScopeSampleAncestor2.count.should == 1
    ScopeSampleAncestor2.all.count.should == 1
    ScopeSampleAncestor2.first.name.should == 'b'
  end
  
  it "shouldn't allow to nest with_exclusive_scope" do
    -> {
      ScopeSample.with_exclusive_scope do
        ScopeSample.with_exclusive_scope{}
      end
    }.should raise_error(/exclusive scope already applied/)
    
    -> {
      ScopeSample.with_exclusive_scope do
        ScopeSample.with_scope{}
      end
    }.should raise_error(/exclusive scope already applied/)
  end
      
  it "with_exclusive_scope should clear other scopes" do
    ScopeSample.send :default_scope, name: 'a'
    
    ScopeSample.with_scope name: 'a' do
      ScopeSample.with_exclusive_scope name: 'b' do        
        ScopeSample.count.should == 1
        ScopeSample.first.name.should == 'b'
      end
    end
  end
  
  it "with_scope" do
    ScopeSample.with_scope name: 'a' do
      ScopeSample.count.should == 1
      ScopeSample.first.name.should == 'a'
    end
  end
  
  it "with scope should merge scope" do
    ScopeSample.class_eval do
      key :name2, String
      key :name3, String
      default_scope name: 'a'
    end
    ScopeSample.create! name: 'a', name2: 'a2', name3: 'a3'
    ScopeSample.create! name: 'b', name2: 'b2', name3: 'b3'
    
    ScopeSample.with_scope name2: 'a2' do
      ScopeSample.with_scope name3: 'a3' do
        ScopeSample.count.should == 1
        ScopeSample.first.name2.should == 'a2'
      end
    end
  end
end