require 'rubygems'
require 'sinatra'
require './csd.rb'

set :environment, ENV['RACK_ENV'].to_sym
set :app_file, './csd.rb'

log = File.new('log/sinatra.log', 'a')
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
