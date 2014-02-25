require 'open-uri'
require 'json'

apimethod = "players.online.names"
username = (File.open('/root/spn_dashboard/jobs/JSONInfo.txt', &:readline)).split[0]
password = (File.open('/root/spn_dashboard/jobs/JSONInfo.txt', &:readline)).split[1]

sha256 = Digest::SHA256.new
sha256.update username
sha256.update apimethod
sha256.update password

factionsUrl = "http://localhost:20065/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Factionsstaff%22%7D%5D"
freebuildUrl = "http://localhost:20059/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Freestaff%22%7D%5D"
hubUrl = "http://localhost:20062/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Hubstaff%22%7D%5D"
kitUrl = "http://localhost:20068/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Kitstaff%22%7D%5D"
prisonUrl = "http://localhost:20071/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Prisonstaff%22%7D%5D"
skyblockUrl = "http://localhost:20074/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skyblockstaff%22%7D%5D"
skywarsUrl = "http://localhost:20077/api/2/call?json=%5B%7B%22name%22%3A%22" + apimethod + "%22%2C%22key%22%3A%22" + sha256.to_s + "%22%2C%22username%22%3A%22" + username + "%22%2C%22arguments%22%3A%5B%5D%2C%22tag%22%3A%22Skywarsstaff%22%7D%5D"

urls = Array.new
urls.push factionsUrl
urls.push freebuildUrl
urls.push hubUrl
urls.push kitUrl
urls.push prisonUrl
urls.push skyblockUrl
urls.push skywarsUrl

# Generate empty hash to store online staff and server locations
staff_locs = Hash.new({ value: 0 })

# Using an array instead of fetching from JSONAPI because the group getter method crashes the server
staff_list = ["bsquidwrd","BigRichieRich","EthanGrievous","Grimdeathkin","Isklar","irRedemption","MiniBuscus","snowboi","The_Smarty_Cat","ThunderWizard","Will124"]
serverPlayers = Array.new
serverNames = ["Factions", "Freebuild", "Hub", "KitPvP", "Prison", "Skyblock", "Skywars"]

SCHEDULER.every '15s' do
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
      staff_list.each { |name|
        if serverPlayers[x].include?(name)
           staff_locs[name] = { label: name, value: serverNames[x]}
        end
      }
    ensure
      x += 1
   end
  end

allPlayers = serverPlayers[0..6].flatten
  staff_list.each { |name|
     if !allPlayers.include?(name)
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
end

