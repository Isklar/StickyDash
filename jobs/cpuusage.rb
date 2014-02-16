# Populate the graph with some random points
points = []

cpuLoad = `top -bn 1 | awk 'NR>7{s+=$9} END {print s/40}'`
cpuInt = Float(cpuLoad.delete!("\n"))

points = []
(1..10).each do |i|
  points << { x: i, y: Integer(cpuInt) }
end
last_x = points.last[:x]

SCHEDULER.every '1m' do

cpuLoad = `top -bn 1 | awk 'NR>7{s+=$9} END {print s/40}'`
cpuInt = Float(cpuLoad.delete!("\n"))

  points.shift
  last_x += 1
  points << { x: last_x, y: Integer(cpuInt) }

  send_event('cpuload', points: points)
end
