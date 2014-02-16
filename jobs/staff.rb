require 'open-uri'
require 'json'

apimethod = "players.online.names"
username = "<Insert your JSONAPI username here>"
password = "<Insert your JSONAPI password here>"

# Generates hash for JSONAPI
sha256 = Digest::SHA256.new
sha256.update username
sha256.update apimethod
sha256.update password

# URL Builders
factionsUrl = "http://localhost:20065/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Factionsstaff%22%7D%5D"
freebuildUrl = "http://localhost:20059/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Freestaff%22%7D%5D"
hubUrl = "http://localhost:20062/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Hubstaff%22%7D%5D"
kitUrl = "http://localhost:20068/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Kitstaff%22%7D%5D"
prisonUrl = "http://localhost:20071/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Prisonstaff%22%7D%5D"
skyblockUrl = "http://localhost:20074/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skyblockstaff%22%7D%5D"
skywarsUrl = "http://localhost:20077/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skywarsstaff%22%7D%5D"

# Generate empty hash to store online staff and server locations
staff_locs = Hash.new({ value: 0 })
# Using an array instead of fetching from JSONAPI because the group getter method crashes the server
staff_list = ["bsquidwrd","BigRichieRich","EthanGrievous","Grimdeathkin","Isklar","irRedemption","MiniBuscus","snowboi","The_Smarty_Cat","ThunderWizard","Will124"]

SCHEDULER.every '15s' do

# This is out of date and does not include error handling for openUri errors
  factionsResponse = JSON.parse(open(factionsUrl).read)[0]
  factionsList = factionsResponse.fetch("success")

  freebuildResponse = JSON.parse(open(freebuildUrl).read)[0]
  freebuildList = freebuildResponse.fetch("success")

  hubResponse = JSON.parse(open(hubUrl).read)[0]
  hubList = hubResponse.fetch("success")

  kitResponse = JSON.parse(open(kitUrl).read)[0]
  kitList = kitResponse.fetch("success")

  prisonResponse = JSON.parse(open(prisonUrl).read)[0]
  prisonList = prisonResponse.fetch("success")

  skyblockResponse = JSON.parse(open(skyblockUrl).read)[0]
  skyblockList = skyblockResponse.fetch("success")

  skywarsResponse = JSON.parse(open(skywarsUrl).read)[0]
  skywarsList = skywarsResponse.fetch("success")

  staff_list.each { |name|
   if factionsList.include?(name)
     staff_locs[name] = { label: name, value: 'Factions'}
   elsif freebuildList.include?(name)
     staff_locs[name] = { label: name, value: 'Freebuild'}
   elsif hubList.include?(name)
     staff_locs[name] = { label: name, value: 'Hub'}
   elsif kitList.include?(name)
     staff_locs[name] = { label: name, value: 'KitPvP'}
   elsif prisonList.include?(name)
     staff_locs[name] = { label: name, value: 'Prison'}
   elsif skyblockList.include?(name)
     staff_locs[name] = { label: name, value: 'Skyblock'}
   elsif skywarsList.include?(name)
     staff_locs[name] = { label: name, value: 'Skywars'}
   else
     staff_locs.delete(name)
   end
  }

  if staff_locs.length == 0
    staff_locs['Nobody'] = { label: 'Nobody', value: ':('}
  else
    if staff_locs.has_key?('Nobody') && staff_locs.length == 1
     staff_locs['Nobody'] = { label: 'Nobody', value: ':('}
    else
     staff_locs.delete('Nobody')
    end
  end

  send_event('staff', { items: staff_locs.values })
#  send_event('debug', { text: FBonlineList })
end

