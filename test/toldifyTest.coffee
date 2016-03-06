Helper = require('hubot-test-helper')
scriptHelper = new Helper('../src/toldify.coffee')
expect = require('chai').expect
util = require '../src/util'

class NewMockResponse extends Helper.Response
  random: (items) ->
    items[1]

describe 'toldify', ->
  this.timeout(5000)
  this.slow(2750)

  before ->
    @room = scriptHelper.createRoom(response: NewMockResponse)

  after ->
    @room.destroy()

  it 'should store a new command', (done) ->
    @room.user.say('alice', '@hubot toldify-add https://raw.githubusercontent.com/seiyria/status-list/master/rekt-list.md, rekt').then ->
    setTimeout (=>
      console.log @room.messages
      expect(@room.messages.length).to.eql 2
      expect(@room.messages[1][1]).to.contain 'URL added with command rekt'
      done()
    ), 2500

  it 'should pick a random line from a stored command', (done) ->
    @room.user.say('alice', '@hubot toldify rekt').then ->
    setTimeout (=>
      console.log @room.messages
      expect(@room.messages.length).to.eql 4
      expect(@room.messages[3][1]).to.contain '[x] REKT'
      done()
    ), 2500

  it 'should reload all data', (done) ->
    utility = new util
    @room.robot.brain.set 'toldify-commands', ['rekt']
    @room.robot.brain.set 'toldify-command-rekt', {url: 'https://raw.githubusercontent.com/seiyria/status-list/master/rekt-list.md', data: ''}
    utility.reloadAllData @room.robot
    setTimeout (=>
      expect(@room.robot.brain.get('toldify-command-rekt').data).to.include('[x] REKT')
      done()
    ), 2500