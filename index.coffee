#!/usr/bin/env ./node_modules/.bin/coffee
epipebomb = require('epipebomb')()

path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './lib');
kijiFormatter = require(lib + "/formatters/kiji_formatter")
dashboardFormatter = require(lib + "/formatters/dashboard_formatter")
globeFormatter = require(lib + "/formatters/globe_formatter")
memberFormatter = require(lib + "/formatters/member_formatter")
distilleryFormatter = require(lib + "/formatters/distillery_formatter")
outbrainFormatter = require(lib + "/formatters/outbrain_formatter")
jsonParser = require(lib + "/json_parser")
newlineSplitter = require(lib + "/newline_splitter")
redis = require 'redis'
client = redis.createClient()
otherClient = redis.createClient()

# gunzip -c test.json.gz | ./index.coffee kiji
process.stdin.setEncoding('utf8')
process.stdin.resume()

formatter = process.argv[2] || 'distillery'
inputStream = process.stdin.pipe(newlineSplitter, { end: false }).pipe(jsonParser, { end: false })
outputStream = require(lib + "/formatters/#{formatter}_formatter")(inputStream)
outputStream.on 'data', (data) ->
  # also write to redis pub sub socket
  client.publish("convorto-pubsub-#{process.argv[2]}", data);
  data = JSON.parse(data)
  data.formatter = formatter
  data = JSON.stringify(data)

  otherClient.publish("convorto-pubsub", data);
# outputStream.pipe(process.stdout,{ end: false })

process.stdin.on 'end', (data) ->
  client.quit()