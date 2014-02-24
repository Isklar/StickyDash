require 'open-uri'
require 'json'

apimethod = "server.version"
username = (File.open('/root/spn_dashboard/jobs/JSONInfo.txt', &:readline)).split[0]
password = (File.open('/root/spn_dashboard/jobs/JSONInfo.txt', &:readline)).split[1]

sha256 = Digest::SHA256.new
sha256.update username
sha256.update apimethod
sha256.update password

factionsUrl = "http://localhost:20065/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22FactionsAlert%22%7D%5D"
freebuildUrl = "http://localhost:20059/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22FreeAlert%22%7D%5D"
hubUrl = "http://localhost:20062/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22HubAlert%22%7D%5D"
kitUrl = "http://localhost:20068/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22KitAlert%22%7D%5D"
prisonUrl = "http://localhost:20071/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22PrisonAlert%22%7D%5D"
skyblockUrl = "http://localhost:20074/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22SkyblockAlert%22%7D%5D"
skywarsUrl = "http://localhost:20077/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22SkywarsAlert%22%7D%5D"

urls = Array.new
urls.push factionsUrl
urls.push freebuildUrl
urls.push hubUrl
urls.push kitUrl
urls.push prisonUrl
urls.push skyblockUrl
urls.push skywarsUrl

serverNames = ["Factions", "Freebuild", "Hub", "KitPvP", "Prison", "Skyblock", "Skywars"]
timeoutCounts = Array.new(7, 0)
alertSent = Array.new(7, 0)

# 10 timeoutCounts = 5m
SCHEDULER.every '30s' do
 x = 0
 urls.each do |url|
  begin
     urlResponse = open(url).read
   rescue Timeout::Error
     puts "The request for a page at #{url} timed out...skipping."
     timeoutCounts[x] += 1
   rescue OpenURI::HTTPError => e
     puts "The request for a page at #{url} returned an error. #{e.message}"
     timeoutCounts[x] += 1
   rescue Errno::ECONNREFUSED
     puts "The request for a page at #{url} refused the connection...skipping."
     timeoutCounts[x] += 1
   else
     timeoutCounts[x] = 0
     alertSent[x] = 0
     #puts "Server #{serverNames[x]} is responding normally."
   ensure
     x += 1
  end
 end

 y = 0
 timeoutCounts.each do |count|
  begin
   # Timedout for more than 5 minutes
   if(count > 10)
     if(count < 20 && alertSent[y] == 0)
       `echo "The #{serverNames[y]} server has not responded in the last 5 mins. Another email will be sent if the server does not respond within 15 minutes" | mail -s "#{serverNames[y]} Server Response Alert" -r "Alerts" -c example@gmail.com`
       alertSent[y] = 1
     end
     if (count > 30 && alertSent[y] != 2)
       `echo "The #{serverNames[y]} server has not responded in the last 15 mins." | mail -s "Urgent #{serverNames[y]} Server Response Alert" -r "Alerts" -c example@gmail.com`
       alertSent[y] = 2
     end
   end
  y += 1 
  end
 end
end

