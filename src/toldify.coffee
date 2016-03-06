# Description:
#   Add a URL pointing to a file to the brain and a res.match filter
#   and hubot will spam the channel with a random line from said file.
#   hubot-toldify will also reload all data once every hour.
#
# Dependencies:
#   "hubot": "2.18.0"
#   "lodash": "4.6.1"
#
# Configuration:
#   NONE!
#
# Commands:
#   hubot toldify-add <url>, <command> - adds a raw file into the brain. Don't forget the comma.
#   hubot toldify-remove <command> - Clears a command
#   hubot toldify <command> - selects a random line from a stored command
#
# Notes:
#   Currently, only empty lines and lines containing '```' are filtered out.
#
# Author:
#   Oipo (Michael de Lang)

util = require './util'

module.exports = (robot) ->

  robot.respond /toldify-add (.+), (.+)/i, (res) ->
    url = res.match[1]
    command = res.match[2]
    utility = new util

    if not utility.isValidUrl url
      res.send "url not a valid url"
      return

    robot.http(url).get() (err, httpRes, body) ->
      if err
        console.err err.stack
        res.send "Encountered an error #{err}"
        return

      if httpRes.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 but with #{httpRes.statusCode} :("
        return

      storedData = utility.convertToData(body, url)

      currentCommands = robot.brain.get "toldify-commands"

      if not currentCommands? or currentCommands.length <= 0
        currentCommands = []

      if currentCommands.indexOf command == -1
        currentCommands.push(command)

      robot.brain.set "toldify-command-#{command}", storedData
      robot.brain.set "toldify-commands", currentCommands

      res.send "URL added with command #{command}"

  robot.respond /toldify-remove/i, (res) ->
    storedData = {}
    robot.brain.set "toldify-command-#{command}", storedData

    res.send "command #{command} cleared"

  robot.respond /toldify ([a-zA-Z0-9]*)/i, (res) ->
    command = res.match[1]

    storedArray = robot.brain.get "toldify-command-#{command}"

    if not storedArray? or Object.keys(storedArray).length <= 0
      res.send "No such command"
      return

    res.send res.random storedArray.data

  ((robot) ->
    setTimeout (->
      utility = new util
      utility.reloadAllData robot
    ), 60*60*1000)(robot)