require 'open-uri'
require 'json'

apimethod = "players.online.names"
username = "<Insert your JSONAPI username here>"
password = "<Insert your JSONAPI password here>"

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

player_counts = Hash.new({ value: 0 })

uniqueFactions = Array.new
uniqueFreebuild = Array.new
uniqueHub = Array.new
uniqueKit = Array.new
uniquePrison = Array.new
uniqueSkyblock = Array.new
uniqueSkywars = Array.new

startTime = "Started at " + Time.now.gmtime.strftime("%H:%M on %d/%m/%Y")
send_event('uniqueplayers', { moreinfo: startTime })

# TODO - Improve if,else statements to remove # do nothing?
SCHEDULER.every '5s' do
  hubResponse = JSON.parse(open(hubUrl).read)[0]
  hubPlayers = hubResponse.fetch("success")

  hubPlayers.each { |name|
    if uniqueHub.include?(name)
      # do nothing?
    else
      uniqueHub.push(name)
    end }
end

SCHEDULER.every '30s' do
  factionsResponse = JSON.parse(open(factionsUrl).read)[0]
  factionsPlayers = factionsResponse.fetch("success")

  freebuildResponse = JSON.parse(open(freebuildUrl).read)[0]
  freebuildPlayers = freebuildResponse.fetch("success")

  kitResponse = JSON.parse(open(kitUrl).read)[0]
  kitPlayers = kitResponse.fetch("success")

  prisonResponse = JSON.parse(open(prisonUrl).read)[0]
  prisonPlayers = prisonResponse.fetch("success")

  skyblockResponse = JSON.parse(open(skyblockUrl).read)[0]
  skyblockPlayers = skyblockResponse.fetch("success")

  skywarsResponse = JSON.parse(open(skywarsUrl).read)[0]
  skywarsPlayers = skywarsResponse.fetch("success")

  factionsPlayers.each { |name|
    if uniqueFactions.include?(name)
      # do nothing?
    else
      uniqueFactions.push(name)
    end }

  freebuildPlayers.each { |name|
    if uniqueFreebuild.include?(name)
      # do nothing?
    else
      uniqueFreebuild.push(name)
    end}

  kitPlayers.each { |name|
    if uniqueKit.include?(name)
      # do nothing?
    else
      uniqueKit.push(name)
    end }

  prisonPlayers.each { |name|
    if uniquePrison.include?(name)
      # do nothing?
    else
      uniquePrison.push(name)
    end }

  skyblockPlayers.each { |name|
    if uniqueSkyblock.include?(name)
      # do nothing?
    else
      uniqueSkyblock.push(name)
    end }

  skywarsPlayers.each { |name|
    if uniqueSkywars.include?(name)
      # do nothing?
    else
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
uniqueFactions.clear
uniqueFreebuild.clear
uniqueHub.clear
uniqueKit.clear
uniquePrison.clear
uniqueSkyblock.clear
uniqueSkywars.clear

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

