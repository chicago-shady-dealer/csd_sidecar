require 'rubygems'
require 'sinatra'
require './csd.rb'

log = File.new('log/sinatra.log', 'a')
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
