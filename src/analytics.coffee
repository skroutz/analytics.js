define [
  'actions_manager'
], (ActionsManager)->
  class Analytics
    constructor: ->
      @manager = new ActionsManager()

  return Analytics
