require 'open-uri'
require 'json'

apimethod = "players.online.names"
username = (File.open('/root/spn_dashboard/jobs/JSONInfo.txt', &:readline)).split[0]
password = (File.open('/root/spn_dashboard/jobs/JSONInfo.txt', &:readline)).split[1]

sha256 = Digest::SHA256.new
sha256.update username
sha256.update apimethod
sha256.update password

factionsUrl = "http://localhost:20065/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Factionsplayers%22%7D%5D"
freebuildUrl = "http://localhost:20059/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Freeplayers%22%7D%5D"
hubUrl = "http://localhost:20062/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Hubplayers%22%7D%5D"
kitUrl = "http://localhost:20068/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Kitplayers%22%7D%5D"
prisonUrl = "http://localhost:20071/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Prisonplayers%22%7D%5D"
skyblockUrl = "http://localhost:20074/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skyblockplayers%22%7D%5D"
skywarsUrl = "http://localhost:20077/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skywarsplayers%22%7D%5D"

urls = Array.new
urls.push factionsUrl
urls.push freebuildUrl
urls.push kitUrl
urls.push prisonUrl
urls.push skyblockUrl
urls.push skywarsUrl

uniqueFactions = Array.new
uniqueFreebuild = Array.new
uniqueHub = Array.new
uniqueKit = Array.new
uniquePrison = Array.new
uniqueSkyblock = Array.new
uniqueSkywars = Array.new

startTime = "Started at " + Time.now.gmtime.strftime("%H:%M on %d/%m/%Y")
send_event('uniqueplayers', { moreinfo: startTime })

serverPlayers = Array.new
player_counts = Hash.new({ value: 0 })

SCHEDULER.every '5s' do
 begin
      hubResponse = open(hubUrl).read
    rescue Timeout::Error
      puts "The request for a page at #{hubUrl} timed out...skipping."
    rescue OpenURI::HTTPError => e
      puts "The request for a page at #{hubUrl} returned an error. #{e.message}"
    rescue Errno::ECONNREFUSED
      puts "The request for a page at #{hubUrl} refused the connection...skipping."
    else
     hubJson = JSON.parse(hubResponse)[0]
     hubPlayers = hubJson.fetch("success")
 end

  hubPlayers.each { |name|
    if !uniqueHub.include?(name)
      uniqueHub.push(name)
    end }
end

SCHEDULER.every '30s' do
  x = 0
  urls.each do |url|
   begin
      urlResponse = open(url).read
    rescue Timeout::Error
      puts "The request for a page at #{url} timed out...skipping."
    rescue OpenURI::HTTPError => e
      puts "The request for a page at #{url} returned an error. #{e.message}"
    rescue Errno::ECONNREFUSED
      puts "The request for a page at #{url} refused the connection...skipping."
    else
      urlJson = JSON.parse(urlResponse)[0]
      serverPlayers[x] = urlJson.fetch("success")
    ensure
      x += 1
   end
  end

  serverPlayers[0].each { |name|
    if !uniqueFactions.include?(name)
      uniqueFactions.push(name)
    end }

  serverPlayers[1].each { |name|
    if !uniqueFreebuild.include?(name)
      uniqueFreebuild.push(name)
    end}

  serverPlayers[2].each { |name|
    if !uniqueKit.include?(name)
      uniqueKit.push(name)
    end }

  serverPlayers[3].each { |name|
    if !uniquePrison.include?(name)
      uniquePrison.push(name)
    end }

  serverPlayers[4].each { |name|
    if !uniqueSkyblock.include?(name)
      uniqueSkyblock.push(name)
    end }

  serverPlayers[5].each { |name|
    if !uniqueSkywars.include?(name)
      uniqueSkywars.push(name)
    end }

  player_counts['Factions'] = { label: 'Factions', value: uniqueFactions.length}
  player_counts['Freebuild'] = { label: 'Freebuild', value: uniqueFreebuild.length}
  player_counts['Hub'] = { label: 'Hub', value: uniqueHub.length}
  player_counts['KitPvP'] = { label: 'KitPvP', value: uniqueKit.length}
  player_counts['Prison'] = { label: 'Prison', value: uniquePrison.length}
  player_counts['Skyblock'] = { label: 'Skyblock', value: uniqueSkyblock.length}
  player_counts['Skywars'] = { label: 'Skywars', value: uniqueSkywars.length}

  send_event('uniqueplayers', { items: player_counts.values })
  send_event('uniqueplayers', { moreinfo: startTime })
end

SCHEDULER.every '24h' do

# clear unique players for all servers
  serverPlayers.clear
  uniqueHub.clear

  player_counts['Factions'] = { label: 'Factions', value: 0}
  player_counts['Freebuild'] = { label: 'Freebuild', value: 0}
  player_counts['Hub'] = { label: 'Hub', value: 0}
  player_counts['KitPvP'] = { label: 'KitPvP', value: 0}
  player_counts['Prison'] = { label: 'Prison', value: 0}
  player_counts['Skyblock'] = { label: 'Skyblock', value: 0}
  player_counts['Skywars'] = { label: 'Skywars', value: 0}

  send_event('uniqueplayers', { items: player_counts.values })

  startTime = "Started at " + Time.now.gmtime.strftime("%H:%M on %d/%m/%Y")
  send_event('uniqueplayers', { moreinfo: startTime })  

  puts "Unique counts reset"
end

