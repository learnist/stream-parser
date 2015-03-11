stream = require 'stream'
flatten = require('flat').flatten

class FlattenOutput extends stream.Transform
  _transform: (obj, encoding, callback) ->
    try
      @push flatten(obj)
    catch error
      console.error "ERROR: #{error}, flatten(obj): ", obj
    callback()
    

module.exports = new FlattenOutput(objectMode: true)