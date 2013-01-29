require 'rubygems'
require 'sinatra'
require './csd.rb'
require 'rack-google-analytics'

log = File.new('log/sinatra.log', 'a')
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
