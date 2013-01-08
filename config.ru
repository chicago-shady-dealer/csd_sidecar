require 'rubygems'
require 'sinatra'

log = File.new('log/sinatra.log', 'a')
$stdout.reopen(log)
$stderr.reopen(log)

require File.expand_path('../csd.rb', __FILE__)

run Sinatra::Application
