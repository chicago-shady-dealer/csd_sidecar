require 'sinatra'
require './models/article.rb'

set :haml, :format => :html5

get '/articles/:id' do
  @article = Article.find(params[:id])
  haml :show
end

get '/articles' do
  redirect '/'
end

get '/' do
  @articles = Article.all
  haml :index
end

get "/styles/*.css" do |path|
  content_type "text/css", charset: "utf-8"
  scss :"scss/#{path}"
end
