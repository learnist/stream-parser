stream = require 'stream'

class StreamFormatter extends stream.Transform
  constructor: ->
    super
    @formatter = (obj) -> obj

  setFormatter: (@formatter) ->

  _transform: (obj, encoding, callback) ->
    data = @formatter(obj)
    @push data if data
    callback()

module.exports = (formatter) ->
  outputStream = new StreamFormatter(objectMode: true)
  outputStream.setFormatter(formatter)
  outputStream
