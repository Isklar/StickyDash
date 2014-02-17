require 'open-uri'
require 'json'

url = "http://status.mojang.com/check"
statuses = Array.new

SCHEDULER.every '15s' do
 statuses.clear
  begin
     urlResponse = open(url).read
   rescue Timeout::Error
     puts "The request for a page at #{url} timed out...skipping."
   rescue OpenURI::HTTPError => e
     puts "The request for a page at #{url} returned an error. #{e.message}"
   else
     result = 1
     website = JSON.parse(urlResponse)[0]["minecraft.net"]
     statuses.push({label: "Website", value: result, arrow: getArrow(website), color: website})     

     login = JSON.parse(urlResponse)[1]["login.minecraft.net"]
     statuses.push({label: "Logins", value: result, arrow: getArrow(login), color: login})

     account = JSON.parse(urlResponse)[3]["account.mojang.com"]
     statuses.push({label: "Accounts", value: result, arrow: getArrow(account), color: account})

     auth = JSON.parse(urlResponse)[6]["authserver.mojang.com"]
     statuses.push({label: "Authentication", value: result, arrow: getArrow(auth), color: auth})

     session = JSON.parse(urlResponse)[7]["sessionserver.mojang.com"]
     statuses.push({label: "Sessions", value: result, arrow: getArrow(session), color: session})

     skins = JSON.parse(urlResponse)[5]["skins.minecraft.net"]
     statuses.push({label: "Skins", value: result, arrow: getArrow(skins), color: skins})
  end

send_event('mojangstatus', {items: statuses})
end

# Determines status icon shown
def getArrow(status)
   if status == "green"
     return "icon-ok-sign"
   elsif status == "yellow"
     return "icon-warning-sign"
   else
     return "icon-thumbs-down" 
   end
end
