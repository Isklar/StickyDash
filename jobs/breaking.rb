require 'open-uri'
require 'json'

url = "http://status.mojang.com/news"

newsGame = "nothing"
newsHeadline = "Hello!"
newsContent = "Welcome to the Sticky Piston Network dashboard."

SCHEDULER.every '15s' do
  begin
     urlResponse = open(url).read
   rescue Timeout::Error
     puts "The request for a page at #{url} timed out...skipping."
   rescue OpenURI::HTTPError => e
     puts "The request for a page at #{url} returned an error. #{e.message}"
   rescue Errno::ECONNREFUSED
     puts "The request for a page at #{url} refused the connection...skipping."
   else
    if !JSON.parse(urlResponse).empty?
     newsGame = JSON.parse(urlResponse)[0].fetch("game")
     if newsGame == "Minecraft"
       newsHeadline = JSON.parse(urlResponse)[0].fetch("headline")
       newsContent = JSON.parse(urlResponse)[0].fetch("message")
       newsContent = newsContent.split('<')[0]
     end    
    end
   end

send_event('welcome', title: newsHeadline, text: newsContent)
end

