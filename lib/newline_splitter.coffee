stream = require 'stream'

# This needs fixed to handle the last line in a file when there is no newline
class NewlineSplitter extends stream.Transform
  constructor: ->
    @_buffer = ""
    super
  
  _transform: (chunk, encoding, callback) ->
    try
      @_buffer += chunk.toString()

      if @_buffer.indexOf("\n") != -1
        parts = @_buffer.split("\n")
        if parts
          for part in parts[0...parts.length - 1]
            @push(part) if part
          @_buffer = parts[parts.length - 1]
    catch error
      console.error "ERROR: #{error}, NewLineSplitter CHUNK: ", chunk
    callback()

module.exports = new NewlineSplitter(encoding: 'utf8')
