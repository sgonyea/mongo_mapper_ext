require 'mongo_mapper'

describe "Special test to check some errors in the MongoMapper" do  
  before :all do
    MongoMapper.database = 'test'
  end
  
  after :all do
    Object.send :remove_const, :ThePost, :TheComment if Object.const_defined? :AnObject
  end
      
  # it "strange behaviour of EmbeddedDocument" do
  #   class TheComment
  #     include MongoMapper::EmbeddedDocument
  #     
  #     key :text, String
  #     alias_method :original_text=, :text=
  #     def text= text
  #       $id_before_save = object_id
  #       self.original_text = text
  #     end
  #     
  #     after_save do
  #       $id_after_save = object_id
  #     end
  #   end
  #   
  #   class ThePost
  #     include MongoMapper::Document
  #     has_many :comments, class_name: 'TheComment'
  #   end    
  #   
  #   ThePost.create! comments: [TheComment.new(text: 'some text')]
  #   $id_before_save.should == $id_after_save
  # end
end