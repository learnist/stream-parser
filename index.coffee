#!/usr/bin/env ./node_modules/.bin/coffee
epipebomb = require('epipebomb')()

path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './lib');
dashboardFormatter = require(lib + "/formatters/dashboard_formatter")
jsonParser = require(lib + "/json_parser")
newlineSplitter = require(lib + "/newline_splitter")
redis = require 'redis'
client = redis.createClient()

process.stdin.setEncoding('utf8')
process.stdin.resume()

inputStream = process.stdin.pipe(newlineSplitter, { end: false }).pipe(jsonParser, { end: false })
dashboardFormatter = require(lib + "/formatters/dashboard_formatter")(inputStream)
dashboardFormatter.on 'data', (data) ->
  # also write to redis pub sub socket
  client.publish("dashBoardPubsub", data);
dashboardFormatter.pipe(process.stdout,{ end: false })

process.stdin.on 'end', (data) ->
  client.quit()