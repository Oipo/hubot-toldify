# Description:
#   Add a URL pointing to a file to the brain and a res.match filter
#   and hubot will spam the channel with a random line from said file
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
#   hubot toldify <command> - selects a random line from a stored command
#
# Notes:
#   Currently, only empty lines and lines containing '```' are filtered out.
#
# Author:
#   Oipo

util = require './util'
_ = require 'lodash'

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
        res.send "Encountered an error #{err}"
        return

      if httpRes.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 but with #{httpRes.statusCode} :("
        return

      bodyArray = body.toString().split '\n'

      _.remove bodyArray, (n) ->
        if n in ['', '```']
          return true
        return false

      robot.brain.set command, bodyArray

      res.send "URL added with command #{command}"

  robot.respond /toldify ([a-zA-Z0-9]*)/i, (res) ->
    command = res.match[1]

    storedArray = robot.brain.get command

    if not storedArray? or storedArray.length <= 0
      res.send "No such command"
      return

    res.send res.random storedArray