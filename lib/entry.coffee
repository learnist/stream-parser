path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './../lib');
Event = require(lib + "/event")
BotDetector = require(lib + "/bot_detector")
MemberDetector = require(lib + "/member_detector")
extend = require('util')._extend
Base64 = require('base64')
geoip = require('geoip-lite')

module.exports = class Entry
  constructor: (@json) ->
    @data = @json.payload
    @cookies = @cookies()
    @guid = @cookies?.guid
    @controller = @data?.controller
    @action = @data?.action
    @params = @data?.params
    @sessionId = @cookies?._learnist_session_ff1
    @deviceId = @params?.device_token
    @responseCode = @data?.response?.status
    @eventName = new Event(@json).eventName()
    @id = @getId()
    @botDetector = new BotDetector(@json)
    # @isMember = new MemberDetector(@guid).isMember()
    @referrer = @data?.headers?.HTTP_NARRATUS_REFERER || @data?.headers?.HTTP_REFERER
    @referer = @referrer
    @userAgent = @data?.headers?.HTTP_NARRATUS_USER_AGENT || @data?.headers?.HTTP_USER_AGENT
    @ip = @data?.headers?.HTTP_NARRATUS_X_REAL_IP || @data?.client_ip
    @path = @data?.path
    @narratus_version = @json.service
    @xForwardedFor = @data?.headers?.HTTP_NARRATUS_X_FORWARDED_FOR || @data?.headers?.HTTP_X_FORWARDED_FOR

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


