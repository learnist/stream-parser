stream = require 'stream'

class ExpandToMultipleLines extends stream.Transform
  _transform: (obj, encoding, callback) ->
    if typeIsArray obj
      for line in obj
        @push line if line
    else
      @push obj if obj
    callback()
    
  typeIsArray = ( value ) ->
    value and
      typeof value is 'object' and
      value instanceof Array and
      typeof value.length is 'number' and
      typeof value.splice is 'function' and
      not ( value.propertyIsEnumerable 'length' )

module.exports = new ExpandToMultipleLines(objectMode: true)