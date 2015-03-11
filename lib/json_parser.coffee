stream = require 'stream'

class JsonParser extends stream.Transform
  constructor: (options) ->
    super

  _transform: (chunk, encoding, callback) ->
    try
      @push JSON.parse(chunk.toString())
    catch error
      console.error "ERROR: #{error}, CHUNK: ", chunk
    callback()

module.exports = new JsonParser(objectMode: true)
