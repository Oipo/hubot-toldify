expect = require('chai').expect
util = require('../src/util')

describe 'util', ->

  it 'should check url validity', ->
    utility = new util

    expect(utility.isValidUrl(' ')).to.eql(false)
    expect(utility.isValidUrl('http://www.google.nl')).to.eql(true)
    expect(utility.isValidUrl('www.google.nl')).to.eql(false)
    expect(utility.isValidUrl('https://www.google.nl')).to.eql(true)
    expect(utility.isValidUrl('ftp://www.google.nl')).to.eql(true)