# # 
# # Connect to database_alias specified in config
# #
# module MongoMapper
#   module Plugins
#     module DbConfig
#       
#       module ClassMethods        
#         inheritable_accessor :database_alias, nil
#         def use_database database_alias
#           self.database_alias = database_alias.to_s
#         end
#         
#         def connection(mongo_connection=nil)
#           assert_supported
#           if mongo_connection.nil?
#             @connection || connection_from_alias || MongoMapper.connection
#           else
#             @connection = mongo_connection
#           end
#         end
# 
#         def database_name
#           assert_supported
#           @database_name || database_name_from_alias
#         end
#         
#         private
#           def database_name_from_alias
#             return unless database_alias
#             
#             MongoMapper.db_config.must.include database_alias
#             MongoMapper.db_config[database_alias]['name']
#           end
#           
#           def connection_from_alias
#             return unless database_alias
#             
#             MongoMapper.db_config.must.include database_alias
#             MongoMapper.connections[database_alias]
#           end
#         
#       end
#       
#     end
#   end
# end