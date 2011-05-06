require 'spec_helper'

require "mongo_mapper_ext/micelaneous"
require "mongo_mapper_ext/plugins/micelaneous"

describe "MongoMapper Default Scope" do
  
  before :all do
    class ::Post
      include MongoMapper::Document      
      include MongoMapper::Plugins::Micelaneous
      
      key :comments_count, Integer, default: 0
      has_many :comments
    end
    
    class ::Comment
      include MongoMapper::Document
      include MongoMapper::Plugins::Micelaneous
      
      key :post_id
      belongs_to :post, counter_cache: true
    end
    
    MongoMapper.database = 'test'
  end
  
  after :all do
    %w{Post Comment Post2 Namespace}.each do |obj_name|
      Object.send :remove_const, obj_name if Object.const_defined? obj_name
    end
  end
  
  before do 
    [Post, Comment].every.delete_all
  end
    
  it "should increase count of comments" do
    post = Post.create!
    comment = post.comments.create!
    
    post.reload
    post.comments_count.should == 1
  end
  
  it "should decrease count of comments" do
    post = Post.create!
    comment = post.comments.create!
    post.reload
    post.comments_count.should == 1
    
    comment.destroy    
    post.reload
    post.comments_count.should == 0
  end
  
  describe "model_name" do
    it "basic" do
      Post.model_name.should == "Post"
      Post.model_name "SuperPost"
      Post.model_name.should == "SuperPost"
    end
    
    it "by default should be initialized from class alias" do
      class ::Post2
        include MongoMapper::Document      
        include MongoMapper::Plugins::Micelaneous

        self.alias 'PostAlias'
      end
      
      module ::Namespace
        class Post
          include MongoMapper::Document      
          include MongoMapper::Plugins::Micelaneous
        end
      end
      
      Post2.model_name.should == 'PostAlias'
      Namespace::Post.model_name.should == 'Post' # not the Namespace::Post
    end
  end
end