path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './../lib');
Event = require(lib + "/event")
BotDetector = require(lib + "/bot_detector")
extend = require('util')._extend
Base64 = require('base64')
geoip = require('geoip-lite')

module.exports = class Entry
  constructor: (@json) ->
    @data = @json
    @params = @data.params
    @userGuid = @data?.user_guid
    @listId = @params?.list_id
  
  eventName: ->
    "#{@data?.controller}:#{@data?.action}" # stupid simplified for ex.
  
  eventData: ->
    if @data.action == 'create' && @data.controller == "tasks"
      out = 
        name: @params?.task?.name
        listId: @params?.task?.list_id
        done: @params?.task?.done
        
    else if @data.action == 'create' && @data.controller == "lists"
      out = 
        name: @params?.list?.name
      
    return out
    
  timestamp: ->
    Number(@json?.timestamp || @json.notification?.start)*1000

  isRobot: ->
    @botDetector.isStupidRobot()

  geo: ->
    geo = geoip.lookup(@ip)
    if geo?.ll?
      { lat: geo.ll[0], lng: geo.ll[1], city: geo.city, country: geo.country, region: geo.region }
    else
      null

  botName: ->
    @botDetector.botName()

  getId: ->
    parseInt(@data?.id || @params?.id)

  requestStart: ->
    (new Date(@json.notification?.start).getTime())

  transaction: ->
    splitTransaction = @json.transaction.split('-')
    transaction = {}
    attrs = ['app', 'env', 'git_commit_version', 'source', 'id']

    for attr in attrs
      transaction[attr] = splitTransaction.shift()

    transaction

  cookies: ->
    cookies = extend({},null)
    if @data?.dispatch_cookies
      cookies = extend(cookies, @data.dispatch_cookies)
    if @data?.cookies
      cookies = extend(cookies, @data.cookies)
    cookies

  isXhr: ->
    /XMLHttpRequest/i.test @data?.headers?.HTTP_X_REQUESTED_WITH

  googleAnalyticsData: ->
    __utma: @cookies?.__utma
    __utmb: @cookies?.__utmb
    __utmc: @cookies?.__utmc
    __utmv: @cookies?.__utmv
    __utmz: @cookies?.__utmz
    _ga: @cookies?._ga

  isRequest: ->
    @json?.notification?.name == "process_action.action_controller"

  compositeGuid: ->
    Base64.encode("#{@userAgent}#{@ip}")

  isLoggingRequest: ->
    !!@controller.match(/logging/i)

  device: ->
    if @params?.device_type
      @params.device_type
    else
      "website"

  formattedUserAgent: ->
    return unless @userAgent?
    if this.isRobot()
      return 'Bot'
    else if @userAgent.match /Googlebot/
      return 'Google'
    else if @userAgent.match /Mozilla\/.+iphone/i
      return 'SPA (mobile)'
    else if @userAgent.match /Prerender/
      return 'Prerender'
    else if @userAgent.match /Mozilla/
      return 'SPA'
    else if match = @userAgent.match /^Dalvik/
      return "Android 0"
    else if match = @userAgent.match /(Mobile|Opera Mini)/
      return 'SPA (mobile)'
    else if match = @userAgent.match /(Mobile|Opera Mini)/
      return 'SPA (mobile)'
    else
      return 'unknown'

  #jsCharacteristics
  isLogging: ->
    #(/LoggingController/.test @controller && (@action == "client" || @action == "javascript"))
    /LoggingController/.test @controller

  loginGuidChanged: ->
    @cookies?.guid != @data?.dispatch_cookies?.guid


