stream = require 'stream'
path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './../lib');
jsonEncoder = require(lib + "/json_encoder")
formatter = require(lib + "/stream_formatter")
filter = require(lib + "/stream_filter")
ColligereEntry = require(lib + "/colligere_entry")

# filterInvalidEntries = (entry) ->
#   entry.eventName && entry.guid && !entry.isSpaAppRequest()
#
entryCreator = formatter((json) -> new ColligereEntry(json))

icpFormatter = (entry) ->
  foo: entry.batchEvents()

module.exports = (inputStream) ->
  inputStream
    # .pipe(filter(selectICPEntries))
    .pipe(entryCreator)
    # .pipe(filter(filterInvalidEntries))
    .pipe(formatter(icpFormatter))

    .pipe(jsonEncoder)