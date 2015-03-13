stream = require 'stream'
path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './../../lib');
jsonEncoder = require(lib + "/json_encoder")
formatter = require(lib + "/stream_formatter")
filter = require(lib + "/stream_filter")
Entry = require(lib + "/entry")

filterInvalidEntries = (entry) ->
  entry.userGuid# && !entry.isRobot()

entryCreator = formatter((json) -> new Entry(json))

dashboardFormatter = (entry) ->
  userGuid: entry.userGuid
  eventName: entry.eventName()
  eventData: entry.eventData()

module.exports = (inputStream) ->
  inputStream
    .pipe(entryCreator, { end: false })
    .pipe(filter(filterInvalidEntries))
    .pipe(formatter(dashboardFormatter), { end: false })
    .pipe(jsonEncoder)