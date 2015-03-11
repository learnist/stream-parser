redis = require 'redis'
client = redis.createClient()

client.on 'message', (channel, message) ->
  console.log message


client.subscribe 'narratus_pub_sub'
