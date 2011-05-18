# Extensions for MongoMapper

## Simultaneous use of multiple databases

    MongoMapper.db_config = {
      'default' => {'name' => "default_test"}
      'global' => {'name' => 'global_test'},      
    }

    # Comment will be connected to :default database
    module Comment
      belongs_to :user
    end

    # User will be connected to :global database
    module User
      use_database :global
      
      has_many :comments
    end
    
## Migrations

    # Works with multiple databases, support versions
    Migration.define :default, 1 do |m|
      m.up{Sample.create name: 'name'}
      m.down{Sample.destroy_all}
    end
    
    # Tell it database and version, and it's smart enough to figure out all needed :up or :down
    Migration.update(:default, 1)
    

## Custom Scope
    :with_scope, :default_scope, :with_exclusive_scope, see spec for details.
    
## Counter Cache

    class Comment
      belongs_to :post, counter_cache: true
    end
    
    Post.comments_count
    
## Attribute Converters

For editing complex objects in forms:

    class Post
      key :tags, Array, as_string: :line
    end
    
    @post.tags_as_string = "personal, article"
    @post.tags                                  # => ['personal', 'article']
    @post.tags_as_string                        # => "personal, article"
    
## Handy upserts

    @post.upsert! :$inc => {comments_count: 1}
    
## CarrierWave integration

File attachments (stored on File System, S3, MongoDB-GridFS)

    class User
      mount_uploader :avatar, AvatarUploader
    end
    
## more

Attribute Cache, Spec Helpers (auto-clean db before each test).

# License

Copyright (c) Alexey Petrushin [http://4ire.net](http://4ire.net), released under the MIT license.