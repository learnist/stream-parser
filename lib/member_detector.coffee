path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './../lib');
members = require(lib + "/members")

module.exports = class MemberDetector
  constructor: (@guid) ->
    
  isMember: ->
    !!members.guids[@guid]