module.exports = class BotDetector

  constructor: (@json) ->
    @_botName = undefined

    @botRegexes = [
      /crawl/i,
      /funweb/i,
      /scoop/i,
      /imgsizer/i,
      /fairshare/i,
      /fetch/i,
      /nutch/i,
      /spider/i,
      /survey/i,
      /bot/i,
      /preview/i,
      /powermark/i,
      /httpunit/i,
      /htmlunit/i,
      /wget/i,
      /curl/i,
      /RebelMouse/i,
      /flipboard/i,
      /(java).*$/i,
      /\+http:\/\//,
      /^NewRelicPinger/,
      /AppEngine/,
      /facebookexternalhit/,
      /facebook.share/,
      /Grockit/,
      /Spinn3r/,
      /Twiceler/,
      /slurp/,
      /Ask.Jeeves/,
      /^Chytach/,
      /^Yandex/,
      /^panscient/,
      /^Netvibes/,
      /^Feed/,
      /^UniversalFeedParser/,
      /^PostRank/,
      /^Apple.PubSub/,
      /ScoutJet/,
      /^Voyager/,
      /oneriot/,
      /js.kit/,
      /backtype.com/,
      /PycURL/,
      /Python.urllib/,
      /^Jakarta/,
      /Butterfly/,
      /^NING/,
      /^Java/,
      /^Ruby/,
      /^Twitturly/,
      /^MetaURI/,
      /daum/,
      /MSNPTC/]

  isStupidRobot: ->
    return true if @_botName != undefined
    userAgent = @json.payload?.headers?.HTTP_USER_AGENT
    return unless userAgent
    for regex in @botRegexes
      if match = userAgent.match regex
        @_botName = userAgent
        return true
    return false

  botName: ->
    if this.isStupidRobot()
      @_botName
      # do something more complicated here to return bot name. for now use entry.formattedUserAgent