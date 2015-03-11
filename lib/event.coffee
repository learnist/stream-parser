module.exports = class Event
  constructor: (json) ->
    @data = json?.payload
    @controller = @data?.controller
    @action = @data?.action
    @params = @data?.params
    @method = @params?.method

  eventName: ->
    if @boards_show()
      "viewed_board"
    else if @learnings_show()
      "viewed_learning"
    else if @search()
      "performed_search"
    else
      null

  search: ->
    @controller == "V2::SearchController" && @action == "boards" ||
    @controller == "V3::SearchController" && @action == "boards"

  boards_show: ->
    (@controller == "BoardsController" && @action == "show") ||
    (@controller == "V2::BoardsController" && @action == "show") ||
    (@controller == "V3::BoardsController" && @action == "show")

  learnings_show: ->
    (@controller == "LearningsController" && @action == "show") ||
    (@controller == "V2::LearningsController" && @action == "show") ||
    (@controller == "V3::LearningsController" && @action == "show")

