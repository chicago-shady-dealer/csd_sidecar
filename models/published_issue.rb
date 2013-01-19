require 'active_resource'

class PublishedIssue < ActiveResource::Base
  self.site = "http://linus.chicagoshadydealer.com"
  self.format = :json
end
