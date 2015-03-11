stream = require 'stream'

class StreamFilter extends stream.Transform
  constructor: ->
    super
    @filter = (obj) -> true
 
  setFilter: (@filter) ->
 
  _transform: (obj, encoding, callback) ->
    @push(obj) if @filter(obj)
    callback()
 
module.exports = (filter) ->
  outputStream = new StreamFilter(objectMode: true)
  outputStream.setFilter(filter)
  outputStream
