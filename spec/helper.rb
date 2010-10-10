dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.expand_path("#{dir}/../../../lib")
$LOAD_PATH << lib_dir unless $LOAD_PATH.include? lib_dir

require 'spec_ext'
gem 'mongo_mapper', '>=0.8'
require "mongo_mapper"
require 'ruby_ext'