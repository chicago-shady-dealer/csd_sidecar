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

get '/styles/main.css' do
  scss :'assets/styles/main'
end
