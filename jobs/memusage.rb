# Populate the graph with some random points
points = []

memSummary = `free`
memPre = memSummary.split(" ")[15]

points = []
(1..10).each do |i|
  points << { x: i, y: Integer(memPre) }
end
last_x = points.last[:x]

SCHEDULER.every '1m' do

  memSummary = `free`
  memUsed = memSummary.split(" ")[15]

  points.shift
  last_x += 1
  points << { x: last_x, y: Integer(memUsed) }

  send_event('memory', points: points)
end
