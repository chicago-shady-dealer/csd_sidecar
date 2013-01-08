require 'active_resource'

class Article < ActiveResource::Base
  self.site = "http://linus.chicagoshadydealer.com"
  self.format = :json
end
