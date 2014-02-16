require 'open-uri'
require 'json'

apimethod = "server.performance.tick_health"
username = "<Insert your JSONAPI username here>"
password = "<Insert your JSONAPI password here>"

sha256 = Digest::SHA256.new
sha256.update username
sha256.update apimethod
sha256.update password

factionsUrl = "http://localhost:20065/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Factionstps%22%7D%5D"
freebuildUrl = "http://localhost:20059/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Freetps%22%7D%5D"
hubUrl = "http://localhost:20062/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Hubtps%22%7D%5D"
kitUrl = "http://localhost:20068/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Kittps%22%7D%5D"
prisonUrl = "http://localhost:20071/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Prisontps%22%7D%5D"
skyblockUrl = "http://localhost:20074/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skyblocktps%22%7D%5D"
skywarsUrl = "http://localhost:20077/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skywarstps%22%7D%5D"

serverTps = Array.new
serverTps << {name: "Factions", progress: 0}
serverTps << {name: "Freebuild", progress: 0}
serverTps << {name: "Hub", progress: 0}
serverTps << {name: "KitPvP", progress: 0}
serverTps << {name: "Prison", progress: 0}
serverTps << {name: "Skyblock", progress: 0}
serverTps << {name: "Skywars", progress: 0}

urls = Array.new
urls.push factionsUrl
urls.push freebuildUrl
urls.push hubUrl
urls.push kitUrl
urls.push prisonUrl
urls.push skyblockUrl
urls.push skywarsUrl

serverNames = ["Factions", "Freebuild", "Hub", "KitPvP", "Prison", "Skyblock", "Skywars"]

SCHEDULER.every '20s' do
x = 0

 urls.each do |url|
  begin
     urlResponse = open(url).read
   rescue Timeout::Error
     puts "The request for a page at #{url} timed out...skipping."
     serverTps[x] = {name: serverNames[x], progress: "Restart"}
   rescue OpenURI::HTTPError => e
     puts "The request for a page at #{url} returned an error. #{e.message}"
     serverTps[x] = {name: serverNames[x], progress: "Restart"}
   else
     urlJson = JSON.parse(urlResponse)[0]
     serverTicks = urlJson.fetch("success").fetch("clockRate").round
     serverTps[x] = {name: serverNames[x], progress: serverTicks}
   ensure
     x += 1
  end
 end

 send_event('tpsbars',{ title: "Server TPS", progress_items: serverTps})
end


