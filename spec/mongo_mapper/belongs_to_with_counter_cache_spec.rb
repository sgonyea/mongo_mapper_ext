require 'mongo_mapper/spec_helper'

describe "BelongsToWithCounterCache" do
  with_mongo_mapper
  
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
  end  
  after(:all){remove_constants :Post, :Comment}
  
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
end