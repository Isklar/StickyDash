# Populate the graph with 0.00 results
points = []
(1..10).each do |i|
  points << { x: i, y: 0 }
end
last_x = points.last[:x]
 
SCHEDULER.every '1m' do
  points.shift
  last_x += 1
  uptime = `cat /proc/loadavg`

# 09:19:37 up 15 days, 14:45,  1 user,  load average: 6.86, 9.58, 10.34
# 11.97 12.32 11.72 14/1673 7035
  loadavg = uptime.split(" ")
  points << { x: last_x, y: loadavg[0].to_f }
 
  send_event('loadavg', points: points)
end
