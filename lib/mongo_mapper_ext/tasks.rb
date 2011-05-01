namespace :db do
  desc "Migrate Database"
  task migrate: :environment do
    ::Migration = MongoMapper::Migration
    Dir["#{rad.config.runtime_dir!}/db/**/*.rb"].each{|f| require f.sub(/\.rb$/, '')}
    
    database_alias = ENV['d'] || ENV['database']
    database_alias = 'default' if database_alias.blank?
    
    version = ENV['v'] || ENV['version']
    if version.blank?
      size = MongoMapper::Migration.definitions[database_alias].size
      highest_defined_version = size == 0 ? 0 : size - 1      
      version = highest_defined_version
    else
      version = version.to_i
    end
    
    MongoMapper::Migration.update database_alias, version
  end
end