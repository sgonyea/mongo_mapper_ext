require 'rspec_ext'

lib_dir = "#{__FILE__.parent_dirname}/lib"
$LOAD_PATH << lib_dir unless $LOAD_PATH.include? lib_dir

gem 'mongo_mapper', '>=0.8'
require "mongo_mapper"

require 'ruby_ext'