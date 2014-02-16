require 'open-uri'
require 'json'

apimethod = "players.online.count"
username = "<Insert your JSONAPI username here>"
password = "<Insert your JSONAPI password here>"

# Generates hash required for JSONAPI
sha256 = Digest::SHA256.new
sha256.update username
sha256.update apimethod
sha256.update password

# URL Builders
factionsUrl = "http://localhost:20065/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Factionscount%22%7D%5D"
freebuildUrl = "http://localhost:20059/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Freecount%22%7D%5D"
hubUrl = "http://localhost:20062/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Hubcount%22%7D%5D"
kitUrl = "http://localhost:20068/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Kitcount%22%7D%5D"
prisonUrl = "http://localhost:20071/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Prisoncount%22%7D%5D"
skyblockUrl = "http://localhost:20074/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skyblockcount%22%7D%5D"
skywarsUrl = "http://localhost:20077/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skywarscount%22%7D%5D"

# URL Array Builder
urls = Array.new
urls.push factionsUrl
urls.push freebuildUrl
urls.push hubUrl
urls.push kitUrl
urls.push prisonUrl
urls.push skyblockUrl
urls.push skywarsUrl

serverNames = ["Factions", "Freebuild", "Hub", "KitPvP", "Prison", "Skyblock", "Skywars"]

player_counts = Hash.new({ value: 0 })

SCHEDULER.every '15s' do
x = 0
total = 0

# Loops through each url and catches timeout and 404 errors, setting the value to NaN for the Tps
 urls.each do |url|
  begin
     urlResponse = open(url).read
   rescue Timeout::Error
     puts "The request for a page at #{url} timed out...skipping."
     player_counts[serverNames[x]] = { label: serverNames[x], value: "Restarting"}
   rescue OpenURI::HTTPError => e
     puts "The request for a page at #{url} returned an error. #{e.message}"
     player_counts[serverNames[x]] = { label: serverNames[x], value: "Restarting"}
   else
     urlJson = JSON.parse(urlResponse)[0]
     serverPlayers = urlJson.fetch("success")
     player_counts[serverNames[x]] = { label: serverNames[x], value: serverPlayers}
     total = total + serverPlayers
   ensure
     x += 1
  end
 end
 # Adds total count to player counts list
  totalString = total.to_s + "/1000"
  player_counts['Total'] = { label: 'Total', value: totalString}
  
# Final send event to update widget
  send_event('players', { items: player_counts.values })
end

