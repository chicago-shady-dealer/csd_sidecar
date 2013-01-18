require 'sinatra'
require 'sanitize'
require './models/article.rb'

set :haml, :format => :html5

ISSUE_ID = 3 # FIXME 

helpers do
  def img(path, alt)
    "<img src='http://linus.chicagoshadydealer.com#{path}' alt='#{alt}' />"
  end

  def primary_img(article)
    image = article.images.first
    path = "http://linus.chicagoshadydealer.com#{image.file.primary.url}"
    alt = image.description
    "<img src='#{path}' alt='#{alt}' />"
  end
  
  def secondary_img(article)
    image = article.images.first
    path = "http://linus.chicagoshadydealer.com#{image.file.secondary.url}"
    alt = image.description
    "<img src='#{path}' alt='#{alt}' />"
  end
  
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def headline_url(article)
    headline = article.headline
    url = "/articles/#{article.id}"
    "<a href='#{url}'>#{headline}</a>"
  end

  def excerpt(article, length)
    body = Sanitize.clean(article.clean_body)
    trunc = body.split(' ')[0..length].join(' ')
    "#{trunc} <a href='/articles/#{article.id}' id='continued'>(continued)</a>"
  end
end

get '/articles/:id' do
  @controller = "show"
  @in_the_news = Article.find(:all, :params => {:issue_id => ISSUE_ID}).sort_by { rand }.slice(0, 5)
  # @from_the_archive = Article.find(:all).select {|a| not a.in? @in_the_news}.sort_by { rand }.slice(0, 5)
  @article = Article.find(params[:id])
  haml :show
end

get '/articles' do
  redirect '/'
end

get '/' do
  @controller = "index"
  
  current_issue = Article.find(:all, :params => {:issue_id => ISSUE_ID})
  @articles_with_images = current_issue.select {|a| not (a.images.nil? or a.images.empty?) }
  
  @primary = @articles_with_images[0]
  @s1 = @articles_with_images[1]
  @s2 = @articles_with_images[2]
  @s3 = @articles_with_images[3]
  
  used_ids = [@primary, @s1, @s2, @s3].map {|a| a.id}
  @rest = current_issue.select {|a| not a.id.in? used_ids}
  @sidebar = @rest[0,3]
  @headlines = @rest[3, @rest.length - 3].sort_by { rand }.slice(0, 5)
  
  haml :index
end

get "/styles/*.css" do |path|
  content_type "text/css", charset: "utf-8"
  scss :"scss/#{path}"
end
