#!/usr/bin/env ./node_modules/.bin/coffee
epipebomb = require('epipebomb')()
path = require('path');
fs   = require('graceful-fs');
npid = require('npid');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './lib');

console.log 'pidfile', process.env['PIDFILE']
if process.env['PIDFILE']
  pid = npid.create process.env['PIDFILE']
  pid.removeOnExit()

dashboardFormatter = require(lib + "/formatters/dashboard_formatter")
redisStream = require(lib + "/redis_stream")
redis = require 'redis'
client = redis.createClient()
narratusClient = redis.createClient()

outputStream = require(lib + "/formatters/dashboard_formatter")(redisStream)
outputStream.on 'data', (data) ->
  data = JSON.parse(data)
  data.formatter = "dashboard"
  data = JSON.stringify(data)
  client.publish("convorto-pubsub", data);

narratusClient.on 'message', (channel, message) ->
  redisStream.write(message)

narratusClient.subscribe 'narratus_pub_sub'

console.log 'initialization finished'