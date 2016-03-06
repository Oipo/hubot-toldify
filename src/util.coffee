_ = require 'lodash'

class Util

  #see https://gist.github.com/dperini/729294
  re_weburl = new RegExp(
    "^" +
    # protocol identifier
    "(?:(?:https?|ftp)://)" +
    # user:pass authentication
    "(?:\\S+(?::\\S*)?@)?" +
      "(?:" +
    # IP address exclusion
    # private & local networks
    "(?!(?:10|127)(?:\\.\\d{1,3}){3})" +
      "(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})" +
      "(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})" +
    # IP address dotted notation octets
    # excludes loopback network 0.0.0.0
    # excludes reserved space >= 224.0.0.0
    # excludes network & broacast addresses
    # (first & last IP address of each class)
    "(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])" +
      "(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}" +
      "(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))" +
      "|" +
    # host name
    "(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)" +
    # domain name
    "(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*" +
    # TLD identifier
    "(?:\\.(?:[a-z\\u00a1-\\uffff]{2,}))" +
    # TLD may end with dot
    "\\.?" +
      ")" +
    # port number
    "(?::\\d{2,5})?" +
    # resource path
    "(?:[/?#]\\S*)?" +
      "$", "i"
    )

  isValidUrl: (url) ->
    return re_weburl.test url

  convertToData: (body, url) ->
    bodyArray = body.toString().split '\n'

    _.remove bodyArray, (n) ->
      if n in ['', '```']
        return true
      return false

    {url: url, data: bodyArray}

  reloadAllData: (robot) ->
    currentCommands = robot.brain.get "toldify-commands"

    if not currentCommands? or currentCommands.length <= 0
      return

    _(currentCommands).forEach (val) =>
      storedArray = robot.brain.get "toldify-command-#{val}"
      url = storedArray.url

      robot.http(url).get() (err, httpRes, body) =>
        if err
          return

        if httpRes.statusCode isnt 200
          return

        storedData = @convertToData(body, url)

        robot.brain.set "toldify-command-#{val}", storedData


module.exports = Util