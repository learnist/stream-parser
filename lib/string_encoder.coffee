stream = require 'stream'

class StringEncoder extends stream.Transform
  _transform: (obj, encoding, callback) ->
    try
      @push obj.toString()
    catch error
      console.error "ERROR: #{error}, StringEncoder obj: ", obj
    callback()

module.exports = new StringEncoder(objectMode: false)
