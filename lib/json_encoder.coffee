stream = require 'stream'

class JsonEncoder extends stream.Transform
  _transform: (obj, encoding, callback) ->
    try
      @push JSON.stringify(obj) + "\n"
    catch error
      console.error "ERROR: #{error}, JsonEncoder obj: ", obj
    callback()

module.exports = new JsonEncoder(objectMode: true)
