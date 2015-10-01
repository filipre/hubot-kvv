# Description
#   A hubot script that accesses http://live.kvv.de/
#
# Configuration:
#   HUBOT_KVV_API_BASE
#   HUBOT_KVV_API_KEY
#
# Commands:
#   hubot kvv - Get depature times at Duale Hochschule
#
# Author:
#   René Filip <renefilip@mail.com>

HUBOT_KVV_API_BASE = if process.env.HUBOT_KVV_API_BASE then process.env.HUBOT_KVV_API_BASE else 'http://live.kvv.de/webapp/'
HUBOT_KVV_API_KEY = if process.env.HUBOT_KVV_API_KEY then process.env.HUBOT_KVV_API_KEY else '377d840e54b59adbe53608ba1aad70e8'

module.exports = (robot) ->

  robot.on "kvv", (kvv) ->

    # de:8212:12 is "Karlsruhe Duale Hochschule"
    requestUrl = HUBOT_KVV_API_BASE + 'departures/bystop/de:8212:12?key=' + HUBOT_KVV_API_KEY + '&maxInfos=4'
    robot.http(requestUrl).get() (err, res, body) ->

      if res.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 :("
        return

      data = null
      try
        data = JSON.parse body
      catch error
        res.send "Ran into an error parsing JSON :("
        return

      # only "Gleis 1"
      departures = (depature for depature in data.departures when depature.stopPosition == '1')

      # build reply
      reply = "Abfahrt ab Duale Hochschule an Gleis 1:"
      for departure in departures
        reply += "\n(#{departure.route}) Richtung #{departure.destination}: #{departure.time}"
      robot.messageRoom kvv.room, reply


  robot.respond /kvv/, (res) ->
    robot.emit "kvv", {
      room: res.message.room
    }
