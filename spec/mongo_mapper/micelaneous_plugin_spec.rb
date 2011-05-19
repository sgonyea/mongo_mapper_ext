require 'mongo_mapper/spec_helper'

describe "Micelaneous" do
  with_mongo_mapper
  
  after(:all){remove_constants :Article, :Post, :Namespace}
  
  describe "model_name" do
    it "basic" do      
      class Article
        include MongoMapper::Document      
        include MongoMapper::Plugins::Micelaneous
      end
      
      Article.model_name.should == "Article"
      Article.model_name "SuperArticle"
      Article.model_name.should == "SuperArticle"
    end
    
    it "by default should be initialized from class alias" do
      class ::Post
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
      
      Post.model_name.should == 'PostAlias'
      Namespace::Post.model_name.should == 'Post' # not the Namespace::Post
    end
  end
end