Helper = require('hubot-test-helper')

scriptHelper = new Helper('../src/toldify.coffee')

expect = require('chai').expect

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
    @room.user.say('alice', '@hubot toldify-add https://raw.githubusercontent.com/seiyria/status-list/master/rekt-list.md, rekt').then =>
      ((room) ->
        setTimeout (->
          console.log room.messages
          expect(room.messages.length).to.eql 2
          expect(room.messages[1][1]).to.contain 'URL added with command rekt'
          done()
        ), 2500)(@room)

  it 'should pick a random line from a stored command', (done) ->
    @room.user.say('alice', '@hubot toldify rekt').then =>
      ((room) ->
        setTimeout (->
          console.log room.messages
          expect(room.messages.length).to.eql 4
          expect(room.messages[3][1]).to.contain '[x] REKT'
          done()
        ), 2500)(@room)
