path = require('path');
fs   = require('graceful-fs');
lib  = path.join(path.dirname(fs.realpathSync(__filename)), './../lib');


class Members
  constructor: () ->
    @guids = {}
    user_guids_path = path.join(path.dirname(fs.realpathSync(__filename)), './../user_guids.csv');
    guids_from_file = ->
      fs.readFileSync user_guids_path, 'utf8'
      
    for guid in guids_from_file().split(',')
      @guids[guid] = 1
    
module.exports = new Members()