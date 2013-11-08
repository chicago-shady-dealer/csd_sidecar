require 'sinatra'
require 'sinatra/content_for'
require 'rack/cache'

require 'sanitize'
require './models/article.rb'
require './models/published_issue.rb'

set :haml, :format => :html5

# Set RACK_ENV to development to override this.
set :environment, :production
#set :environment, :development

ISSUE_ID     = 78 # PublishedIssue.find(:last).id # FIXME 
TOP_STORY_ID = 217

if settings.environment == :production
    use Rack::Cache,
        :verbose => true,
        :metastore => "file:/tmp/cache/meta",
        :entitystore => "file:/tmp/cache/body"

    before do
        cache_control :public, :must_revalidate, :max_age => 600
    end
end

helpers do
  def img(path, alt)
    "<img src='http://linus.chicagoshadydealer.com#{path}' alt='#{alt}' />"
  end

  def primary_img(article)
    image = article.image
    path = "http://linus.chicagoshadydealer.com#{image.file.primary.url}"
    alt = image.description
    "<img src='#{path}' alt='#{alt}' />"
  end
  
  def secondary_img(article)
    image = article.image
    path = "#{image.file.secondary.url}"
    alt = image.description
    "<img src='http://linus.chicagoshadydealer.com#{path}' alt='#{alt}' />"
  end
  
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def pretty_url(article)
    "/articles/#{article.id}-#{article.headline.downcase.gsub(/\W/,'-').squeeze('-').chomp('-')}"
  end

  def headline_link(article)
    headline = article.headline
    "<a href='#{pretty_url(article)}'>#{headline}</a>"
  end

  def pdf_link(url)
    "<a href='http://linus.chicagoshadydealer.com#{url}'>(PDF)</a>"
  end

  def excerpt(article, length)
    body = Sanitize.clean(article.clean_body)
    trunc = body.split(' ')[0..length].join(' ')
    "#{trunc} <a href='/articles/#{article.id}' id='continued'>(continued)</a>"
  end
end

get '/' do
  @controller = "index"
  
  top_story = Article.find(TOP_STORY_ID)
  current_issue = Article.find(:all, :params => {:issue_id => ISSUE_ID})
  @articles_by_images = current_issue.select {|a| (a.id != TOP_STORY_ID) }
                          .sort_by {|a| a.image.file.url.present? ? 0 : 1 }
  
  @primary = top_story 
  @s1 = @articles_by_images[0]
  @s2 = @articles_by_images[1]
  @s3 = @articles_by_images[2]
  
  used_ids = [@primary, @s1, @s2, @s3].map {|a| a.id}
  @rest = current_issue.select {|a| not a.id.in? used_ids}
  @sidebar = @rest.shift(4)
  @headlines = @rest
  
  haml :index
end

get '/afd' do
  haml :afd, :layout => :plain
end

get '/articles' do
    redirect '/'
end

get '/articles/:id' do
  @controller = "show"
  @article = Article.find(params[:id])
  last_modified @article.updated_at
  @in_the_news = Article.find(:all, :params => {:issue_id => ISSUE_ID})
  haml :show
end

get '/about' do
  @controller = "about"
  haml :about
end

get '/archive' do
  @controller = "archive"
  @issues = {}
  PublishedIssue.find(:all).map do |i|
    if @issues[i.volume].nil?
      @issues[i.volume] = {}
    end
    @issues[i.volume][i.issue] =
      [i.published_issue.url,
       if i.volume >= 9 then
         Article.find(:all, :params => {:issue_id => i})
       else [] end]
  end

  haml :archive
end

get '/feed.xml' do
  @articles = Article.find(:all).last(10)
  
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => '2.0' do
      xml.channel do
        xml.title "Chicago Shady Dealer"
        xml.description "The latest stories from the University of Chicago's only intentional humor publication."
        xml.link "http://chicagoshadydealer.com"

        @articles.each do |article|
          xml.item do
            xml.title       article.headline
            xml.link        pretty_url(article)
            xml.description article.clean_body
            xml.pubDate     Time.parse(article.created_at.to_s).rfc822()
            xml.guid        pretty_url(article)
          end
        end
      end
    end
  end
end

get "/styles/*.css" do |path|
  content_type "text/css", charset: "utf-8"
  scss :"scss/#{path}"
end
